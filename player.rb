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
    matrix = board.pieces_for(@color).reject { |piece| piece.valid_moves.empty?}
    current_piece = matrix.sample
    display_with_new_highlight(current_piece.pos)
    end_pos = current_piece.valid_moves.sample
    display_with_new_highlight(end_pos)
    @display.highlighted = []
    board.move_piece(current_piece.pos, end_pos)
  end

  def display_with_new_highlight(pos)
    @display.highlighted << pos
    @display.render
    print_turn
    sleep(0.5)
  end
end
