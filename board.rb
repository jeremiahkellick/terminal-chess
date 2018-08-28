require_relative "piece"
require_relative "slideable"
require_relative "stepable"
require_relative "pawn"

# Board.make_board => Board.new

class Board

  # # factory method. special class method that makes new instances
  # def self.make_board
  #   grid
  #
  #   Board.new(grid)
  # end


  def initialize
    row = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    @kings = {}
    black_rows, white_rows = [:black, :white].map do |color|
      royal_row = row.map do |piece_class|
        new_piece = piece_class.new(nil, self, color)
        @kings[color] = new_piece if piece_class == King
        new_piece
      end
      pawn_row = 8.times.map { Pawn.new(nil, self, color) }
      color == :black ? [royal_row, pawn_row] : [pawn_row, royal_row]
    end
    middle = Array.new(4) { Array.new(8, NullPiece.instance) }
    @grid = black_rows + middle + white_rows
    fix_piece_positions
    @last_move = nil
    @destroyed_piece = nil
  end

  def fix_piece_positions
    @grid.each_with_index do |row, row_i|
      row.each_with_index do |piece, col_i|
        piece.pos = [row_i, col_i] unless piece.null?
      end
    end
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end

  def move_piece(start_pos, end_pos, check_validity = true)
    piece = self[start_pos]
    raise ArgumentError, "there is no piece at start_pos" if piece.nil?
    if check_validity
      raise InvalidMoveError unless move_valid?(start_pos, end_pos)
    end
    self[start_pos] = NullPiece.instance
    @last_move = [start_pos, end_pos]
    @destroyed_piece = self[end_pos]
    self[end_pos] = piece
    piece.pos = end_pos
  end

  def move_valid?(start_pos, end_pos)
    valid_pos?(start_pos) &&
    !self[start_pos].null? &&
    self[start_pos].valid_moves.include?(end_pos)
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord >= 0 && coord <= 7 }
  end

  def in_check?(color)
    king_pos = @kings[color].pos
    other_team_color = color == :white ? :black : :white
    pieces_for(other_team_color).any? { |piece| piece.moves.include?(king_pos) }
  end

  def checkmate?(color)
    in_check?(color) && pieces_for(color).all? do |piece|
      piece.valid_moves.empty?
    end
  end

  def pieces_for(color)
    result = []
    @grid.each do |row|
      row.each { |piece| result << piece if piece.color == color }
    end
    result
  end

  def undo
    moved_piece = self[@last_move[1]]
    self[@last_move[0]] = moved_piece
    moved_piece.pos = @last_move[0]
    self[@last_move[1]] = @destroyed_piece
    @destroyed_piece.pos = @last_move[1]
  end

  private

  def []=(pos, value)
    @grid[pos[0]][pos[1]] = value
  end
end

class InvalidMoveError < StandardError
end
