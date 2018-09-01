require_relative "add_pos"

module Slideable
  HORIZONTAL_DIRS = [[1,0], [0,-1], [-1,0], [0,1]]
  DIAGONAL_DIRS = [[1,-1], [-1,-1], [-1,1], [1,1]]

  def horizontal?
    false
  end

  def diagonal?
    false
  end

  def move_dirs
    (horizontal? ? HORIZONTAL_DIRS : []) + (diagonal? ? DIAGONAL_DIRS : [])
  end

  def moves
    result = []
    move_dirs.each { |dir| result.concat(grow_unblocked_moves_in_dir(dir)) }
    result
  end

  def grow_unblocked_moves_in_dir(dir)
    blocked = false
    current_pos = @pos
    result = []
    until blocked
      blocked = true
      current_pos = add_pos(current_pos, dir)
      on_board = @board.valid_pos?(current_pos)
      if on_board && @board[current_pos].color != color
        result << current_pos
        blocked = false if @board[current_pos].null?
      end
    end
    result
  end
end

class Rook < Piece
  include Slideable

  def horizontal?
    true
  end

  def letter
    "R"
  end

  def unicode
    "\u2656"
  end
end

class Bishop < Piece
  include Slideable

  def diagonal?
    true
  end

  def letter
    "B"
  end

  def unicode
    "\u2657"
  end
end

class Queen < Piece
  include Slideable

  def horizontal?
    true
  end

  def diagonal?
    true
  end

  def letter
    "Q"
  end

  def unicode
    "\u2655"
  end
end
