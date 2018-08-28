require_relative "piece"

# Board.make_board => Board.new

class Board

  # # factory method. special class method that makes new instances
  # def self.make_board
  #   grid
  #
  #   Board.new(grid)
  # end


  def initialize
    @grid = Array.new(8) {Array.new(8, NullPiece.instance) }
    fill_board
  end

  def fill_board
    (@grid[0..1] + @grid[-2..-1]).each_with_index do |row, row_i|
      row.each_index {|i| row[i] = Piece.new([row_i, i], self, :white) }
    end
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    raise ArgumentError, "there is no piece at start_pos" if piece.nil?
    raise InvalidMoveError unless move_valid?(start_pos, end_pos)
    self[start_pos] = nil
    self[end_pos] = piece
    piece.pos = end_pos
  end

  def move_valid?(start_pos, end_pos)
    [start_pos, end_pos].all? { |pos| valid_pos?(pos) }
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord >= 0 && coord <= 7 }
  end
  
  private

  def []=(pos, value)
    @grid[pos[0]][pos[1]] = value
  end
end

class InvalidMoveError < StandardError
end
