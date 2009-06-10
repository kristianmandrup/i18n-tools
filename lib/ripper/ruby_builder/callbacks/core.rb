class Ripper
  class RubyBuilder < Ripper::SexpBuilder
    module Core
      def on_ident(token)
        Ruby::Identifier.new(token, position, pop_whitespace)
      end

      def on_kw(token)
        if %w(class def do end not and or).include?(token)
          return push(super) 
        else
          Ruby::Keyword.new(token, position, pop_whitespace)
        end
      end

      def on_int(token)
        Ruby::Integer.new(token, position, pop_whitespace)
      end

      def on_float(token)
        Ruby::Float.new(token, position, pop_whitespace)
      end

      def on_const(token)
        Ruby::Const.new(token, position, pop_whitespace)
      end

      def on_class(const, super_class, body)
        rdelim = pop_delim(:@kw, :value => 'end')
        operator = pop_delim(:@op)
        ldelim = pop_delim(:@kw, :value => 'class')
        Ruby::Class.new(const, operator, super_class, body, ldelim, rdelim)
      end

      def on_def(identifier, params, body)
        rdelim, ldelim = stack_ignore(:@op, :@comma, :@lparen, :@rparen) do 
          pop_delims(:@kw, :value => %w(def end))
        end
        Ruby::Method.new(identifier, params, body, ldelim, rdelim)
      end

      def on_const_ref(const)
        const # not sure what to do here
      end

      def on_field(field)
        field # not sure what to do here
      end

      def on_var_ref(ref)
        ref # not sure what to do here
      end

      def on_var_field(field)
        field # not sure what to do here
      end
    end
  end
end