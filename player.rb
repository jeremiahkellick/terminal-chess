class Player
  def initialize(color, display)
    @color = color
    @display = display
    @assist_mode = true
  end

  def print_turn
    puts "#{@color.to_s.capitalize}'s turn"
  end
end

class HumanPlayer < Player
  def make_move(board)
    selected_pos = get_pos { |pos| board.valid_piece_to_move?(pos, @color) }
    @display.highlighted = board[selected_pos].valid_moves if @assist_mode
    piece = board[selected_pos]
    move_to_pos = get_pos { |pos| piece.valid_moves.include?(pos) }
    board.move_piece(selected_pos, move_to_pos)
    @display.highlighted = []
  end

  def get_pos(&prc)
    loop do
      @display.render
      print_turn
      pos = @display.cursor.get_input
      return pos if pos.is_a?(Array) && prc.call(pos)
    end
  end
end

class ComputerPlayer < Player
  def make_move(board)
    possible_moves = []
    possible_pieces = pieces_with_moves(board)
    possible_pieces.each do |piece|
      piece.valid_moves.each do |move|
        possible_moves << [piece.pos, move] unless board[move].null?
      end
    end
    if possible_moves.empty?
      piece = possible_pieces.sample
      possible_moves << [piece.pos, piece.valid_moves.sample]
    end
    move = possible_moves.sample
    display_with_new_highlight(move[0])
    display_with_new_highlight(move[1])
    @display.highlighted = []
    board.move_piece(move[0], move[1])
  end

  def display_with_new_highlight(pos)
    @display.highlighted << pos
    @display.render
    print_turn
    sleep(0.5)
  end

  def pieces_with_moves(board)
    board.pieces_for(@color).reject { |piece| piece.valid_moves.empty? }
  end
end
