require 'core_ext/object/meta_class'
require 'ruby/composite'

module Ruby
  class Node
    class << self
      def from_native(object, position = nil, whitespace = nil)
        from_ruby(object.inspect, position, whitespace)
      end
      
      def from_ruby(src, position = nil, whitespace = nil)
        Ripper::RubyBuilder.new(src).parse.statements.first.tap do |node|
          node.position = position if position
          node.whitespace = whitespace if whitespace
          # p whitespace
          # p node.whitespace
        end
      end
    end
    
    include Ansi
    include Composite

    attr_writer :whitespace

    def initialize(position = nil, whitespace = nil)
      self.position = position.dup if position
      self.whitespace = whitespace if whitespace
    end

    def row
      position[0]
    end

    def column
      position[1]
    end

    def position
      @position || nodes.each { |n| return n.position.dup if n } && nil # raise("position not set in #{self.class}")
    end
    
    def position=(position)
      @position = position.dup
    end
    
    def whitespace
      @whitespace || nodes.each { |n| return n.whitespace if n } && ''
    end

    def length(include_whitespace = false)
      to_ruby(include_whitespace).length
    end

    def to_ruby(include_whitespace = false)
      (include_whitespace ? whitespace : '') + nodes.map { |node| node.to_ruby(true) }.join.strip
    end
    
    def nodes
      []
    end

    def filename
      root? ? @filename : root.filename
    end

    def src_pos(include_whitespace = false)
      line_pos(row) + column - (include_whitespace ? whitespace.length : 0)
    end

    def src(include_whitespace = false)
      root? ? @src : root.src[src_pos(include_whitespace), length(include_whitespace)]
    end

    def lines
      root.src.split("\n")
    end

    def line_pos(row)
      (row > 0 ? lines[0..(row - 1)].inject(0) { |pos, line| pos + line.length + 1 } : 0)
    end

    # TODO what if a node spans multiple lines (like a block, method definition, ...)?
    def line(highlight = false)
      line = lines[row].dup
      highlight ? line_head + ansi_format(to_ruby, [:red, :bold]) + line_tail : line
    end

    # excerpt from source, preceding and succeeding [Ruby.context_width] lines
    def context(highlight = false)
      (context_head + [line(highlight)] + context_tail).join("\n")
    end

    def context_head
      min = [0, row - Ruby.context_width].max
      min < row ? lines[min..(row - 1)] : []
    end

    def context_tail
      max = [row + Ruby.context_width, lines.size].min
      max > row ? lines[(row + 1)..max] : []
    end

    # all content that precedes the node in the first line of the node in source
    def line_head
      line[0..(column - 1)].to_s
    end

    # all content that succeeds the node in the last line of the node in source
    def line_tail
      line[(column + length - 1)..-1].to_s
    end
    
    protected
    
      def from_ruby(*args)
        self.class.from_ruby(*args)
      end
    
      def from_native(*args)
        self.class.from_native(*args)
      end

      def position_from(node, column_offset = 0)
        @position = node.position.dup
        @position[1] -= column_offset
      end

      def update_positions(row, column, offset_column)
        pos = self.position
        pos[1] += offset_column if pos && self.row == row && self.column > column
        children.each { |c| c.send(:update_positions, row, column, offset_column) }
      end
  end
end