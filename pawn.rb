require_relative "add_pos"

class Pawn < Piece
  def initialize(pos, board, color)
    super
    @vertical = color == :white ? -1 : 1
  end

  def moves
    result = []
    straight_pos = add_pos(@pos, straight_diff)
    result << straight_pos if @board.valid_pos?(straight_pos) &&
                              @board[straight_pos].null?
    diagonal_diffs.each do |diff|
      new_pos = add_pos(@pos, diff)
      if @board.valid_pos?(new_pos) &&
         !@board[new_pos].null? &&
         @board[new_pos].color != @color

        result << new_pos
      end
    end
    result
  end

  def diagonal_diffs
    [[@vertical, -1], [@vertical, 1]]
  end

  def straight_diff
    [@vertical, 0]
  end
end
