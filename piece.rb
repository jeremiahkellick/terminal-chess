require 'singleton'

class Piece
  UNICODE = true

  attr_accessor :pos, :color

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
    @moved = false
  end

  def on_move(start_pos, end_pos)
    @moved = true
  end

  def to_s
    Piece.unicode? ? unicode : letter
  end

  def letter
    raise NotImplementedError
  end

  def unicode
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

  def self.unicode?
    UNICODE
  end

  protected

  def moved?
    @moved
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

  def on_move(start_pos, end_pos); end
end

class EnPassantPiece
  attr_reader :piece_to_destroy
  attr_accessor :pos

  def initialize(pos, piece_to_destroy)
    @piece_to_destroy = piece_to_destroy
    @pos = pos
    @should_be_deleted = false
  end

  def color
    :null_color
  end

  def to_s
    " "
  end

  def null?
    true
  end

  def on_move(start_pos, end_pos); end

  def should_be_deleted?
    return_val = @should_be_deleted
    @should_be_deleted = true
    return_val
  end
end
