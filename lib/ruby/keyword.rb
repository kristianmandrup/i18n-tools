require 'ruby/node'

module Ruby
  class Keyword < Identifier
    @@keywords = {
      'true'     => true,
      'false'    => false,
      'nil'      => nil,
      'and'      => 'and',
      'or'       => 'or',
      'not'      => 'not',
      'class'    => 'class',
      'def'      => 'def',
      'do'       => 'do',
      'end'      => 'end',
      '__FILE__' => '__FILE__',
      '__LINE__' => '__LINE__'
    }
    
    def initialize(token, position = nil)
      super
      raise("unsupported keyword: #{token}") unless @@keywords.has_key?(token)
    end
    
    def value
      @@keywords[token]
    end
    
    def to_ruby
      token
      # @@keywords.invert[token]
    end
  end
end