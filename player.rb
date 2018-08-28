class Player
  def initialize(color, display)
    @color = color
    @display = display
    @assist_mode = true
  end
end

class HumanPlayer < Player
  def make_move(board)
    selected_pos = nil
    until selected_pos
      @display.render
      input = @display.cursor.get_input
      if input.is_a?(Array) &&
         !board[input].null? &&
         !board[input].valid_moves.empty? &&
         board[input].color == @color

        selected_pos = input
      end
    end
    @display.highlighted = board[selected_pos].valid_moves if @assist_mode
    piece = board[selected_pos]
    move_to_pos = nil
    until move_to_pos
      @display.render
      input = @display.cursor.get_input
      move_to_pos = input if input.is_a?(Array) && piece.valid_moves.include?(input)
    end
    board.move_piece(selected_pos, move_to_pos)
    @display.highlighted = []
  end
end

class ComputerPlayer < Player
  def make_move(board)
    matrix = board.pieces_for(@color).reject { |piece| piece.valid_moves.empty?}
    current_piece = matrix.sample
    @display.highlighted = [current_piece.pos]
    @display.render
    sleep(0.5)
    end_pos = current_piece.valid_moves.sample
    @display.highlighted << end_pos
    @display.render
    sleep(1)
    @display.highlighted = []
    board.move_piece(current_piece.pos, end_pos)
  end
end
