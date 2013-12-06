load 'AI.rb'
load 'player.rb'

module OhMyChess

  PIECE_WIDTH  = 62
  PIECE_HEIGHT = 62
  TOP_OFFSET = 47
  LEFT_OFFSET = 12

  class Game
    BOARD_SIZE = [5,4] # [col, row]

    attr_accessor :board, :difficulty
        
    def initialize
      @agent          = AlphaBeta.new new_board
      @player_1       = Player.new(:black, :human)
      @player_2       = Player.new(:white, :robot)
      @board          = new_board
      @difficulty     = 1
      @game_status    = :running
    end

    def finished?
      @game_status == :finished
    end

    def lock?
      @game_lock == :lock
    end

    def available_moves?
      @board.each do |pos|
        return true if pos == 0
      end
      false
    end

    def next_turn
      @current_player = next_player
      if @current_player.role == :robot
        # AI
        coord = @agent.find_best_move @board, @player_2.color, @player_1.color
        lay_piece(coord)
        next_turn if !finished?
      end
    end

    def current_player
      @current_player ||= @player_1
    end

    def next_player
      current_player == @player_1 ? @player_2 : @player_1
    end

    # Build the array for the board, with zero-based arrays.
    def new_board
      Array.new(BOARD_SIZE[0]) do # build each cols L to R
        Array.new(BOARD_SIZE[1]) do # insert cells in each col
          0
        end
      end
    end
    
    def lay_piece(coords)
      piece = current_player.piece
      opp_piece = current_player.opp_piece
      raise "Spot already taken." if board_at(coords) != 0
      @board[coords[0]][coords[1]] = piece
      @game_status = :finished if calculate_current_winner current_player, coords
    end

    def calculate_current_winner player, coords
      color = player.piece

      # vertical
      if @board[coords[0]][0] == color && @board[coords[0]][1] == color && 
        @board[coords[0]][2] == color && @board[coords[0]][3] == color
        return true
      end

      # horizontal
      if @board[0][coords[1]] == color && @board[1][coords[1]] == color &&
        @board[2][coords[1]] == color && @board[3][coords[1]] == color
        return true
      elsif @board[1][coords[1]] == color && @board[2][coords[1]] == color &&
        @board[3][coords[1]] == color && @board[4][coords[1]] == color
        return true
      end
      
      # diagonal
      if @board[0][0] == color && @board[1][1] == color && 
        @board[2][2] == color && @board[3][3] == color
        return true
      elsif @board[1][0] == color && @board[2][1] == color && 
        @board[3][2] == color && @board[4][3] == color
        return true
      elsif @board[0][3] == color && @board[1][2] == color && 
        @board[2][1] == color && @board[3][0] == color
        return true
      elsif @board[1][3] == color && @board[2][2] == color && 
        @board[3][1] == color && @board[4][0] == color
        return true
      end

      false
    end
    
    # Find the value of the board at the given coordinate.
    def board_at(coords)
      @board[coords[0]][coords[1]]
    end

    private
      def pieces_per_player
        total_squares / 2
      end
      
      # The total number of squares
      def total_squares
        BOARD_SIZE[0] * BOARD_SIZE[1]
      end
    # end of Game
  end

  def status_bar(message)
    stack :margin => 10 do
      background white
      para span("Difficulty #{GAME.difficulty} | #{message}", :stroke => red, :font => "Trebuchet 20px bold"), :margin => 4
    end
  end

  def draw_board(message="#{GAME.current_player.role} turn")
    clear do
      background black
      message = "#{GAME.current_player.role} win!!" if GAME.finished?
      status_bar(message)
      stack :margin => 10 do

        GAME.board.each_with_index do |row, row_index|
          row.each_with_index do |cell, col_index|
            left, top = left_top_corner_of_piece(row_index, col_index)
            left = left - LEFT_OFFSET
            top = top - TOP_OFFSET - 12
            fill rgb(0, 440, 0, 90)
            strokewidth 1
            stroke rgb(0, 100, 0)
            rect :left => left, :top => top, :width => PIECE_WIDTH, :height => PIECE_HEIGHT

            if cell != 0
              strokewidth 0
              fill (cell == 1 ? rgb(100,100,100) : rgb(155,155,155))
              oval(left+3, top+4, PIECE_WIDTH-10, PIECE_HEIGHT-10)

              fill (cell == 1 ? black : white)
              oval(left+5, top+5, PIECE_WIDTH-10, PIECE_HEIGHT-10)
            end
          end
        end
      end

      button("-",
        :bottom => 0, 
        :left => 0) do 
        GAME.difficulty -= 1 if GAME.difficulty > 1
        draw_board
      end
      button("+",
        :bottom => 0, 
        :left => 60) do 
        GAME.difficulty += 1 if GAME.difficulty < 3
        draw_board
      end
    end
  end

  def left_top_corner_of_piece(a,b)
    [(a*PIECE_WIDTH+LEFT_OFFSET), (b*PIECE_HEIGHT+TOP_OFFSET+12)]
  end

  def right_bottom_corner_of_piece(a,b)
    [((a+1)*PIECE_WIDTH+LEFT_OFFSET), ((b+1)*PIECE_HEIGHT+TOP_OFFSET+12)]
  end

  def find_piece(x,y)
    GAME.board.each_with_index { |col_array, col| 
      col_array.each_with_index { |row_array, row| 
        left, top = left_top_corner_of_piece(col, row).map { |i| i }
        right, bottom = right_bottom_corner_of_piece(col, row).map { |i| i }
        return [col, row] if x >= left && x <= right && y >= top && y <= bottom
      } 
    }
    return false
  end

  GAME = OhMyChess::Game.new
end


Shoes.app :width => 333, :height => 343 do
  extend OhMyChess

  draw_board
  
  click { |button, x, y| 
    if (coords = find_piece(x,y)) && !GAME.finished?
      begin
        GAME.lay_piece(coords)
        GAME.next_turn if !GAME.finished?
        draw_board
      rescue => e
        draw_board(e)
      end
    else
      # alert("Not a piece.")
    end
  }
end
