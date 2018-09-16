require_relative "piece"
require_relative "slideable"
require_relative "stepable"
require_relative "pawn"

class Board
  # promotion_proc should return :queen, :knight, :rook, or :bishop
  def initialize(promotion_proc)
    @promotion_proc = promotion_proc
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
    @destroyed_piece = NullPiece.instance
    @moved_piece = NullPiece.instance
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
    @moved_piece = piece
    self[end_pos] = piece
    piece.pos = end_pos
    if piece.is_a?(Pawn) && @destroyed_piece.is_a?(EnPassantPiece)
      self[@destroyed_piece.piece_to_destroy.pos] = NullPiece.instance
    end
    if check_validity
      promote(piece) if piece.promotion_due?
      clear_en_passants
      if piece.is_a?(Pawn) && (start_pos[0] - end_pos[0]).abs > 1
        self[piece.behind_pos] = EnPassantPiece.new(piece.behind_pos, piece)
      end
    end
  end

  def clear_en_passants
    @grid.each do |row|
      row.each do |piece|
        self[piece.pos] = NullPiece.instance if piece.is_a?(EnPassantPiece)
      end
    end
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
    in_check?(color) && no_moves?(color)
  end

  def winner
    checkmated = [:black, :white].find { |color| checkmate?(color) }
    if checkmated
      checkmated == :black ? :white : :black
    else
      nil
    end
  end

  def no_moves?(color)
    pieces_for(color).all? { |piece| piece.valid_moves.empty? }
  end

  def pieces_for(color)
    result = []
    @grid.each do |row|
      row.each { |piece| result << piece if piece.color == color }
    end
    result
  end

  def undo
    self[@last_move[0]] = @moved_piece
    @moved_piece.pos = @last_move[0]
    self[@last_move[1]] = @destroyed_piece
    @destroyed_piece.pos = @last_move[1]
    if @destroyed_piece.is_a?(EnPassantPiece)
      pos = @destroyed_piece.piece_to_destroy.pos
      self[pos] = @destroyed_piece.piece_to_destroy
    end
  end

  def valid_piece_to_move?(pos, color)
    !self[pos].null? &&
    !self[pos].valid_moves.empty? &&
    self[pos].color == color
  end

  private

  def []=(pos, value)
    @grid[pos[0]][pos[1]] = value
  end

  def promote(piece)
    # @promotion_proc should return :queen, :knight, :rook, or :bishop
    new_piece_class = Object.const_get(@promotion_proc.call.capitalize)
    new_piece = new_piece_class.new(piece.pos, self, piece.color)
    self[piece.pos] = new_piece
  end
end

class InvalidMoveError < StandardError
end
