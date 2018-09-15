class Player
  attr_reader :color

  def initialize(color, display)
    @color = color
    @display = display
    @assist_mode = true
  end

  def turn_string
    "#{@color.to_s.capitalize}'s turn"
  end

  def get_promotion
    raise NotImplementedError
  end
end

class HumanPlayer < Player
  def make_move(board)
    selected_pos = @display.get_pos(turn_string, false) do |pos|
      board.valid_piece_to_move?(pos, @color)
    end
    @display.highlighted = board[selected_pos].valid_moves if @assist_mode
    piece = board[selected_pos]
    move_to_pos = @display.get_pos(turn_string) do |pos|
      piece.valid_moves.include?(pos)
    end
    board.move_piece(selected_pos, move_to_pos)
    @display.highlighted = []
  rescue EscapeError
    @display.highlighted = []
    retry
  end

  def get_promotion
    system("clear")
    puts <<~MESSAGE
      Choose promotion:
      (q)ueen
      (k)night
      (r)ook
      (b)ishop
      (v)iew board
    MESSAGE
    response = STDIN.getch
    raise RuntimeError, "Invalid input" unless %w(q k r b v).include?(response)
    if response == "v"
      system("clear")
      @display.highlighted = []
      @display.render(false)
      pause
      return get_promotion
    end
    { "q" => :queen, "k" => :knight, "r" => :rook, "b" => :bishop }[response]
  rescue RuntimeError => e
    if e.message == "Invalid input"
      puts e.message
      retry
    else
      raise
    end
  end

  def pause
    puts "Press any key"
    STDIN.getch
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

  def get_promotion
    :queen
  end

  def display_with_new_highlight(pos)
    @display.highlighted << pos
    @display.render(false)
    print_turn
    sleep(0.5)
  end

  def pieces_with_moves(board)
    board.pieces_for(@color).reject { |piece| piece.valid_moves.empty? }
  end
end
