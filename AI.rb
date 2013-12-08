class AlphaBeta

  # pattern weight
  INFINITY = 9999         # win
  THREE = 400             # live three or one way three
  LIVE_TWO = 100          # could be live three in next step
  ONE_WAY_TWO = 40        # could be one way three in next step
  LIVE_ONE = 15           # could be live two in next step
  ONE_WAY_ONE = 10        # could be one way two in next step
  GOOD_POS = 3            # in the critical aera

  DEPTH = 1

  attr_accessor :sandbox_board, :best_step, :difficulty

  def initialize _board, _difficulty=1
    @sandbox_board = _board
    @critical_area = [[1,1],[2,1],[3,1],[1,2],[2,2],[3,2]]
    @best_step = []
    @difficulty = _difficulty
    ## for the test
    # @max_color = 1
    # @min_color = 2
  end

  # am I go first?
  def me_go_first
    @critical_area.sample
  end

  # alphabeta
  # return [column, row]
  def find_best_move _board, max_color, min_color
    @sandbox_board = _board.clone
    @max_color = max_color
    @min_color = min_color
    p max_score -INFINITY, INFINITY, 0
    p @best_step.last
    return @best_step.pop if @best_step.any?
    remaining_moves.sample
  end

  # MAX
  def max_score alpha, beta, counter

    if counter >= @difficulty+DEPTH
      return get_value
    end

    score = -INFINITY

    remaining_moves.each do |coord|
      make_a_move coord, @max_color
      tmp = min_score(alpha, beta, counter+1)
      if tmp > score
        score = tmp
        if  counter == 0
          @best_step.pop if @best_step.any?
          @best_step.push coord
        end
      end
      # score = [min_score(alpha, beta, counter+1), score].max
      undo_a_move coord
      return score if score >= beta
      alpha = [alpha, score].max
    end
    p "max: #{counter}, #{score}"
    score
  end

  # MIN
  def min_score alpha, beta, counter

    if counter >= @difficulty+DEPTH
      return get_value
    end

    score = INFINITY

    remaining_moves.each do |coord|
      make_a_move coord, @min_color

      score = [max_score(alpha, beta, counter+1), score].min
      undo_a_move coord
      return score if score <= alpha
      beta = [beta, score].min
    end

    p "min: #{counter}, #{score}"
    score
  end


  # make a move in sandbox board
  def make_a_move coord, _color
    @sandbox_board[coord[0]][coord[1]] = _color
  end

  # undo a move, for recurrence
  def undo_a_move coord
    @sandbox_board[coord[0]][coord[1]] = 0
  end


  # get values
  def get_value
    score = winner?
    return score if score != 0

    score = { :gpos => 0, 
              :three => 0,
              :ltwo => 0, :otwo => 0,
              :lone => 0, :ooone => 0 }

    # start rating
    # good position
    score[:gpos] = good_pos

    # check three
    score[:three] = three

    p GOOD_POS*score[:gpos]+
    THREE*score[:three]+
    LIVE_TWO*score[:ltwo]+ONE_WAY_TWO*score[:otwo]+
    LIVE_ONE*score[:lone]+ONE_WAY_ONE*score[:ooone]
  end


  # check three, stupid but work ...
  def three
    bo = @sandbox_board
    three_score = 0
    # vertical
    bo.each do |col|
      # [1110],[0111],[1011],[1101]
      if (col[0]==@max_color && col[1]==@max_color && 
        col[2]==@max_color && col[3]==0) ||
        (col[1]==@max_color && col[2]==@max_color && 
        col[3]==@max_color && col[0]==0) ||
        (col[0]==@max_color && col[2]==@max_color && 
        col[3]==@max_color && col[1]==0) ||
        (col[0]==@max_color && col[1]==@max_color && 
        col[3]==@max_color && col[2]==0)
        three_score+=1
      elsif (col[0]==@min_color && col[1]==@min_color && 
        col[2]==@min_color && col[3]==0) ||
        (col[1]==@min_color && col[2]==@min_color && 
        col[3]==@min_color && col[0]==0) ||
        (col[0]==@min_color && col[2]==@min_color && 
        col[3]==@min_color && col[1]==0) ||
        (col[0]==@min_color && col[1]==@min_color && 
        col[3]==@min_color && col[2]==0)
        three_score-=1
      end
    end

    # horizontal
    (0..3).each do |row|
      # [1110*],[0111*],[*1110],[*0111],
      ## [1011*],[1101*],[*1011],[*1101]
      if (bo[0][row]==@max_color &&
        bo[1][row]==@max_color &&
        bo[2][row]==@max_color &&
        bo[3][row]==0) ||
      (bo[2][row]==@max_color &&
        bo[3][row]==@max_color &&
        bo[4][row]==@max_color &&
        bo[1][row]==0)
        three_score+=1
      elsif (bo[0][row]==@min_color &&
        bo[1][row]==@min_color &&
        bo[2][row]==@min_color &&
        bo[3][row]==0) || 
      (bo[2][row]==@min_color &&
        bo[3][row]==@min_color &&
        bo[4][row]==@min_color &&
        bo[1][row]==0)
        three_score+=1
      elsif (bo[1][row]==@max_color &&
        bo[2][row]==@max_color &&
        bo[3][row]==@max_color &&
        (bo[0][row]==0||bo[4][row]==0))
        three_score+=2
      elsif (bo[1][row]==@min_color &&
        bo[2][row]==@min_color &&
        bo[3][row]==@min_color &&
        (bo[0][row]==0||bo[4][row]==0))
        three_score-=2
      end
    end

    # diagonal

    three_score+=1 if checker([1, 1], [3, 3], 3, @max_color)&&bo[0][0] == 0
    three_score+=1 if checker([2, 1], [4, 3], 3, @max_color)&&bo[1][0] == 0
    three_score-=1 if checker([1, 1], [3, 3], 3, @min_color)&&bo[0][0] == 0
    three_score-=1 if checker([2, 1], [4, 3], 3, @min_color)&&bo[1][0] == 0

    three_score+=1 if checker([0, 3], [2, 1], 3, @max_color)&&bo[3][0] == 0
    three_score+=1 if checker([1, 3], [3, 1], 3, @max_color)&&bo[4][0] == 0
    three_score-=1 if checker([0, 3], [2, 1], 3, @min_color)&&bo[3][0] == 0
    three_score-=1 if checker([1, 3], [3, 1], 3, @min_color)&&bo[4][0] == 0
 
    three_score+=1 if checker([1, 2], [3, 0], 3, @max_color)&&bo[0][3] == 0
    three_score+=1 if checker([2, 2], [4, 0], 3, @max_color)&&bo[1][3] == 0
    three_score-=1 if checker([1, 2], [3, 0], 3, @min_color)&&bo[0][3] == 0
    three_score-=1 if checker([2, 2], [4, 0], 3, @min_color)&&bo[1][3] == 0

    three_score+=1 if checker([0, 0], [2, 2], 3, @max_color)&&bo[3][3] == 0
    three_score+=1 if checker([1, 0], [3, 2], 3, @max_color)&&bo[4][3] == 0
    three_score-=1 if checker([0, 0], [2, 2], 3, @min_color)&&bo[3][3] == 0
    three_score-=1 if checker([1, 0], [3, 2], 3, @min_color)&&bo[4][3] == 0


    three_score
  end

  # here is all the good position
  def good_pos
    pos_score = 0
    @critical_area.each do |pos|
      pos_score+=1 if @sandbox_board[pos[0]][pos[1]] == @max_color
      pos_score-=1 if @sandbox_board[pos[0]][pos[1]] == @min_color
    end
    pos_score
  end


  # am I win????
  def winner?
    # vertical
    (0..4).to_a.each do |i|
      return INFINITY if checker [i,0], [i,3], 4, @max_color
      return -INFINITY if checker [i,0], [i,3], 4, @min_color
    end

    # horizontal
    (0..3).to_a.each do |i|
      return INFINITY if checker [0,i], [3,i], 4, @max_color
      return INFINITY if checker [1,i], [4,i], 4, @max_color
      return -INFINITY if checker [0,i], [3,i], 4, @min_color
      return -INFINITY if checker [1,i], [4,i], 4, @min_color
    end
    # diagonal
    return INFINITY if checker [0,0], [3,3], 4, @max_color
    return INFINITY if checker [1,0], [4,3], 4, @max_color
    return INFINITY if checker [3,0], [0,3], 4, @max_color
    return INFINITY if checker [4,0], [1,3], 4, @max_color

    return -INFINITY if checker [0,0], [3,3], 4, @min_color
    return -INFINITY if checker [1,0], [4,3], 4, @min_color
    return -INFINITY if checker [3,0], [0,3], 4, @min_color
    return -INFINITY if checker [4,0], [1,3], 4, @min_color

    0
  end


  # check if the same color in a line
  def checker start_c, end_c, step, color
    step_col = (end_c[0] + 1 - start_c[0])/step
    step_row = (end_c[1] + 1 - start_c[1])/step

    (0..step-1).each do |i|
      if @sandbox_board[start_c[0]+i*step_col][start_c[1]+i*step_row] != color
        return false
      end
    end
    true
  end


  # return an array of the avaliable moves in random order
  def remaining_moves _board = @sandbox_board
    remaining_cell = Array.new
    _board.each_with_index do |array, column|
      array.each_with_index do |val, row|
        remaining_cell.push([column, row]) if val == 0
      end
    end
    remaining_cell.shuffle
  end
end


#
#
# for unit test
#
#

# def new_board val=0
#   Array.new(5) do # build each cols L to R
#     Array.new(4) do # insert cells in each col
#       val
#     end
#   end
# end


# board = new_board 0


# board[4][0] = 2
# board[0][0] = 2
# board[2][1] = 2
# board[3][1] = 2
# board[0][3] = 2

# board[1][3] = 1
# board[1][1] = 1
# board[1][2] = 1
# board[2][2] = 1
# board[3][2] = 1

# agent = AlphaBeta.new board

# agent.find_best_move board, 1, 2
# p agent.get_value


