require 'singleton'

class Piece
  attr_accessor :pos, :color

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def to_s
    "#"
  end

  def moves
    raise NotImplementedError
  end

  def null?
    false
  end
end

class NullPiece
  include Singleton

  def color
    :null_color
  end

  def to_s
    " "
  end

  def null?
    true
  end
end
