require 'colorize'
class Piece
  attr_accessor :pos

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def to_s
    "#"
  end
end

class NilClass
  def to_s
    "#"
  end
end
