require 'singleton'

class Piece
  attr_accessor :pos, :color

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def to_s
    raise NotImplementedError
  end

  def moves
    raise NotImplementedError
  end

  def null?
    false
  end

  def valid_moves
    moves.reject do |move|
      @board.move_piece(@pos, move, false)
      in_check = @board.in_check?(@color)
      @board.undo
      in_check
    end
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

  def pos=(value); end
end
