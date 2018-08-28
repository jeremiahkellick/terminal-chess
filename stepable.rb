require_relative "add_pos"

module Stepable
  def moves
    result = []
    move_diffs.each do |diff|
      new_pos = add_pos(@pos, diff)
      if @board.valid_pos?(new_pos) && @board[new_pos].color != @color
        result << new_pos
      end
    end
    result
  end

  def move_diffs
    raise NotImplementedError
  end
end

class King < Piece
  include Stepable

  def move_diffs
    [[1,0], [0,-1], [-1,0], [0,1], [1,-1], [-1,-1], [-1,1], [1,1]]
  end

  def to_s
    "K"
  end
end

class Knight < Piece
  include Stepable

  def move_diffs
    [[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2],[1,2],[2,1]]
  end

  def to_s
    "N"
  end
end
