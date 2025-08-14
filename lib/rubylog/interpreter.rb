# lib/rubylog/interpreter.rb
module Rubylog
  class Interpreter
    # Simple persistent KB so separate Interpreter instances share facts/rules across test calls
    @@facts = []  # each fact is a Rubylog::Node(:predicate, name, args...)
    @@rules = []  # each rule  is [head_predicate_node, body_goal_node]

    def self.reset!
      @@facts.clear
      @@rules.clear
    end

    def initialize(ast)
      @ast = ast
    end

    # Evaluate a full program node.
    # Returns:
    # - true/false for ground queries
    # - Array<Hash> of substitutions for non-ground queries (variables present)
    def evaluate
      raise "Interpreter expects a Rubylog::Node" unless @ast.is_a?(Rubylog::Node)
      raise "Top-level node must be :program" unless @ast.type == :program

      result = nil
      @ast.children.each do |clause|
        case clause.type
        when :fact
          predicate = clause.children.first
          store_fact(predicate)
          # facts don't produce a result; keep last non-nil result (e.g., from a query)
        when :rule
          head = clause.children[0]
          body = clause.children[1]
          store_rule(head, body)
        when :query
          goal = clause.children.first
          solutions = solve_goals(flatten_goals(goal), {})

          if contains_variables?(goal)
            # Return array of binding hashes like {"X" => "alice"}
            result = solutions.map { |env| pretty_bindings(env) }
          else
            # Ground query: return boolean
            result = !solutions.empty?
          end
        else
          raise "Unknown top-level clause type: #{clause.type}"
        end
      end

      result
    end

    private

    # --- Knowledge base ---

    def store_fact(pred_node)
      @@facts << pred_node
    end

    def store_rule(head_pred, body_goal)
      @@rules << [head_pred, body_goal]
    end

    # --- Goal solving (DFS backtracking) ---

    # Returns array of envs (Hash<String, Rubylog::Node>) that satisfy all goals
    def solve_goals(goals, env)
      if goals.empty?
        return [env]
      end

      first, *rest = goals
      solutions = []

      # Try matching facts
      each_matching_fact(first) do |fact_pred|
        env2 = unify_predicates(first, fact_pred, env)
        next unless env2
        solutions.concat(solve_goals(rest, env2))
      end

      # Try rules
      each_matching_rule(first) do |head_pred, body_goal|
        env2 = unify_predicates(first, head_pred, env)
        next unless env2
        new_goals = flatten_goals(body_goal) + rest
        solutions.concat(solve_goals(new_goals, env2))
      end

      solutions
    end

    def each_matching_fact(goal_pred)
      name, arity = predicate_name(goal_pred), predicate_arity(goal_pred)
      @@facts.each do |fact_pred|
        next unless predicate_name(fact_pred) == name
        next unless predicate_arity(fact_pred) == arity
        yield fact_pred
      end
    end

    def each_matching_rule(goal_pred)
      name, arity = predicate_name(goal_pred), predicate_arity(goal_pred)
      @@rules.each do |head_pred, body_goal|
        next unless predicate_name(head_pred) == name
        next unless predicate_arity(head_pred) == arity
        yield [head_pred, body_goal]
      end
    end

    # --- Predicate helpers ---

    def predicate_name(pred_node)
      raise "Expected :predicate, got #{pred_node.type}" unless pred_node.type == :predicate
      pred_node.children[0] # String name (e.g., "parent")
    end

    def predicate_args(pred_node)
      pred_node.children[1..] || []
    end

    def predicate_arity(pred_node)
      predicate_args(pred_node).size
    end

    # --- Goal flattening (handle :and trees to a flat goal list) ---

    def flatten_goals(goal_node)
      case goal_node.type
      when :predicate
        [goal_node]
      when :and
        left, right = goal_node.children
        flatten_goals(left) + flatten_goals(right)
      else
        raise "Unknown goal node type: #{goal_node.type}"
      end
    end

    # --- Unification ---

    # Unify two predicate nodes under env; returns new env or nil on failure
    def unify_predicates(p1, p2, env)
      return nil unless predicate_name(p1) == predicate_name(p2)
      a1 = predicate_args(p1)
      a2 = predicate_args(p2)
      return nil unless a1.size == a2.size

      a1.zip(a2).reduce(env) do |e, (t1, t2)|
        e ? unify_terms(t1, t2, e) : nil
      end
    end

    # Unify terms (atoms, variables, numbers, strings, predicates)
    # env maps variable name String => bound Rubylog::Node
    def unify_terms(t1, t2, env)
      t1 = deref(t1, env)
      t2 = deref(t2, env)

      # Variable cases
      if variable?(t1)
        return bind_var(t1, t2, env)
      elsif variable?(t2)
        return bind_var(t2, t1, env)
      end

      # Atoms / numbers / strings
      if leaf?(t1) && leaf?(t2) && t1.type == t2.type
        return (leaf_value(t1) == leaf_value(t2)) ? env : nil
      end

      # Structured terms: allow predicate-ish terms on RHS/LHS (functors)
      if t1.type == :predicate && t2.type == :predicate
        return unify_predicates(t1, t2, env)
      end

      nil
    end

    def variable?(node)
      node.is_a?(Rubylog::Node) && node.type == :variable
    end

    def leaf?(node)
      node.is_a?(Rubylog::Node) && [:atom, :number, :string, :variable].include?(node.type)
    end

    def leaf_value(node)
      # Leaf nodes are constructed like Node(:atom, "alice")
      node.children[0]
    end

    # Follow bindings if a variable is already bound
    def deref(term, env)
      while variable?(term) && env.key?(leaf_value(term))
        term = env[leaf_value(term)]
      end
      term
    end

    def bind_var(var_node, value, env)
      vname = leaf_value(var_node) # String like "X"
      # Occurs-check (simple): prevent X = f(X, ...) infinite structures
      return nil if occurs?(vname, value, env)
      new_env = env.dup
      new_env[vname] = value
      new_env
    end

    def occurs?(var_name, term, env)
      term = deref(term, env)
      return true if variable?(term) && leaf_value(term) == var_name
      return false unless term.is_a?(Rubylog::Node)
      # Check inside predicate args or leaf children
      term.children.any? { |child| occurs?(var_name, child, env) }
    end

    # --- Variables detection & pretty output ---

    def contains_variables?(goal)
      case goal.type
      when :predicate
        predicate_args(goal).any? { |t| contains_var_in_term?(t) }
      when :and
        goal.children.any? { |g| contains_variables?(g) }
      else
        false
      end
    end

    def contains_var_in_term?(t)
      return true if variable?(t)
      return false unless t.is_a?(Rubylog::Node)
      t.children.any? { |c| contains_var_in_term?(c) }
    end

    # Convert env bindings into {"X" => "alice"} etc.
    # If a variable is bound to an atom/number/string, show its leaf value.
    # If bound to a structured term, keep it as a Rubylog::Node (you can pretty-print later).
    def pretty_bindings(env)
      env.transform_values do |val|
        val = deref(val, env)
        if leaf?(val)
          leaf_value(val)
        elsif val.type == :predicate
          # minimal stringification: name(args...)
          name = val.children[0]
          args = predicate_args(val).map { |a| leaf?(a) ? leaf_value(a) : a.inspect }
          "#{name}(#{args.join(', ')})"
        else
          val.inspect
        end
      end
    end
  end
end
