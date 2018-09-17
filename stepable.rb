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

  def valid_moves
    result = super
    [:left, :right].each do |direction|
      rook_pos = direction == :left ? [pos[0], 0] : [pos[0], 7]
      diff = direction == :left ? -1 : 1
      rook = @board[rook_pos]
      spaces = get_spaces_between_castle(rook_pos, diff)
      can_castle = !moved? &&
        rook.is_a?(Rook) &&
        !rook.moved? &&
        spaces.all? { |space| @board[space].null? } &&
        !@board.in_check?(color) &&
        none_in_check(spaces)
      result << [pos[0], pos[1] + diff * 2] if can_castle
    end
    result
  end

  def on_move(start_pos, end_pos)
    super
    horizontal_diff = end_pos[1] - start_pos[1]
    if horizontal_diff.abs == 2
      sign = horizontal_diff > 0 ? 1 : -1
      rook_pos = [pos[0], sign == 1 ? 7 : 0]
      @board.move_piece(rook_pos, [pos[0], pos[1] - sign], false)
    end
  end

  def unicode
    "\u265A"
  end

  def letter
    "K"
  end

  private

  def get_spaces_between_castle(rook_pos, diff)
    current_space = [pos[0], pos[1] + diff]
    spaces = []
    until current_space == rook_pos
      spaces << current_space
      current_space = [current_space[0], current_space[1] + diff]
    end
    spaces
  end

  def none_in_check(spaces)
    spaces.none? do |space|
      @board.move_piece(pos, space, false)
      in_check = @board.in_check?(color)
      @board.undo
      in_check
    end
  end
end

class Knight < Piece
  include Stepable

  def move_diffs
    [[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2],[1,2],[2,1]]
  end

  def unicode
    "\u265E"
  end

  def letter
    "N"
  end
end
