require_relative "add_pos"

class Pawn < Piece
  def initialize(pos, board, color)
    super
    @vertical = color == :white ? -1 : 1
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
      result << pos if @board.valid_pos?(pos) && @board[pos].null?
    end
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

  def straight_positions
    if @pos[0] == @starting_row
      [add_pos(@pos, straight_diff), add_pos(@pos, [@vertical * 2, 0])]
    else
      [add_pos(@pos, straight_diff)]
    end
  end

  def to_s
    "P"
  end
end
