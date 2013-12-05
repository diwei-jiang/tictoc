class AlphaBeta

  INFINITY = 4
  GOOD_MOVE = 2
  DIFFCULTY = 3

  attr_accessor :sandbox_board, :history

  def initialize sandbox_board
    @sandbox_board = sandbox_board
    @critical_area = [[1,1],[2,1],[3,1],[1,2],[2,2],[3,2]]
    @history = Array.new
  end

  # alphabeta
  # return [column, row]
  def find_best_move board, max_color, min_color
    @sandbox_board = board.clone
    @max_color = max_color
    @min_color = min_color
    max_score -INFINITY, INFINITY, 1
    return @history.pop
  end

  def max_score alpha, beta, counter

    result = terminal_test
    # p "max: #{result}"
    return result if result

    score = -INFINITY

    remaining_moves.each do |coord|
      make_a_move coord, @max_color
      score = GOOD_MOVE if good_move coord
      tmp = min_score(alpha, beta, counter+1)
      if (tmp >= score) && counter == 1
        score = tmp
        @history.pop if @history.any?
        @history.push coord
        p @history
      end
      # score = [min_score(alpha, beta, counter+1), score].max
      undo_a_move coord
      return score if score >= beta || counter > DIFFCULTY
      alpha = [alpha, score].max
    end

    score
  end

  def min_score alpha, beta, counter
    result = terminal_test
    # p "min: #{result}"
    return result if result

    score = INFINITY

    remaining_moves.each do |coord|
      score = -GOOD_MOVE if good_move coord
      make_a_move coord, @min_color
      score = [max_score(alpha, beta, counter+1), score].min
      undo_a_move coord
      return score if score <= alpha || counter > DIFFCULTY
      beta = [beta, score].min
    end

    score
  end

  def good_move coord
    return true if @critical_area.include? coord
    false
  end

  def make_a_move coord, _color
    @sandbox_board[coord[0]][coord[1]] = _color
  end

  def undo_a_move coord
    @sandbox_board[coord[0]][coord[1]] = 0
  end

  def terminal_test
    if (utility = winner?)
      return utility
    end

    if remaining_moves.count == 0
      return 0
    end

    false
  end

  def winner?
    # vertical
    (0..4).to_a.each do |i|
      return INFINITY if checker [i,0], [i,3], 1
      return -INFINITY if checker [i,0], [i,3], 2
    end

    # horizontal
    (0..3).to_a.each do |i|
      return INFINITY if checker [0,i], [3,i], 1
      return INFINITY if checker [1,i], [4,i], 1
      return -INFINITY if checker [0,i], [3,i], 2
      return -INFINITY if checker [1,i], [4,i], 2
    end
    # diagonal
    return INFINITY if checker [0,0], [3,3], 1
    return INFINITY if checker [1,0], [4,3], 1
    return -INFINITY if checker [3,0], [0,3], 2
    return -INFINITY if checker [4,0], [1,3], 2

    false
  end

  def checker start_c, end_c, color
    step_col = (end_c[0] + 1 - start_c[0])/4
    step_row = (end_c[1] + 1 - start_c[1])/4

    if @sandbox_board[start_c[0]][start_c[1]] == color &&
      @sandbox_board[start_c[0]+step_col][start_c[1]+step_row] == color &&
      @sandbox_board[start_c[0]+2*step_col][start_c[1]+2*step_row] == color &&
      @sandbox_board[start_c[0]+3*step_col][start_c[1]+3*step_row] == color
      return true
    end
    false
  end


  def remaining_moves
    remaining_cell = Array.new
    @sandbox_board.each_with_index do |array, column|
      array.each_with_index do |val, row|
        remaining_cell.push([column, row]) if val == 0
      end
    end
    remaining_cell
  end
end


def new_board val=0
  Array.new(5) do # build each cols L to R
    Array.new(4) do # insert cells in each col
      val
    end
  end
end


# board = new_board 0

# agent = AlphaBeta.new board

# board[0][1] = 1

# p agent.winner?

# p agent.remaining_moves

# p agent.find_best_move board, 1, 2

# p agent.history


