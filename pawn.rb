require_relative "add_pos"

class Pawn < Piece
  def initialize(pos, board, color)
    super
    @vertical = color == :white ? -1 : 1
    @promotion_row = color == :white ? 0 : 7
    @first_time_pos_set = true
    @starting_row = nil
  end

  def pos=(value)
    super
    if @first_time_pos_set
      @starting_row = value[0]
      @first_time_pos_set = false
    end
  end

  def moves
    result = []
    straight_positions.each do |pos|
      if @board.valid_pos?(pos) && @board[pos].null?
        result << pos
      else
        break
      end
    end
    diagonal_diffs.each do |diff|
      new_pos = add_pos(@pos, diff)
      if @board.valid_pos?(new_pos)
        piece = @board[new_pos]
        if (!piece.null? && piece.color != @color) ||
           (piece.is_a?(EnPassantPiece) &&
            piece.piece_to_destroy.color != @color)

          result << new_pos
        end
      end
    end
    result
  end

  def on_move(start_pos, end_pos)
    super
    if (start_pos[0] - end_pos[0]).abs > 1
      @board[behind_pos] = EnPassantPiece.new(behind_pos, self)
    end
    @board.promote(self) if promotion_due?
  end

  def diagonal_diffs
    [[@vertical, -1], [@vertical, 1]]
  end

  def straight_diff
    [@vertical, 0]
  end

  def straight_positions
    if @pos[0] == @starting_row
      [add_pos(@pos, straight_diff), add_pos(@pos, [@vertical * 2, 0])]
    else
      [add_pos(@pos, straight_diff)]
    end
  end

  def letter
    "P"
  end

  def unicode
    "\u265F"
  end

  private

  def promotion_due?
    @pos[0] == @promotion_row
  end

  def behind_pos
    [pos[0] - @vertical, pos[1]]
  end
end
