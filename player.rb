class Player
  attr_accessor :color, :role

  def initialize(color=:black, role=:human)
    @color = color
    @role  = role
  end

  # return the color value
  def piece
    @color == :black ? 1 : 2
  end
          
  def opp_piece
    @color == :black ? 2 : 1
  end
end