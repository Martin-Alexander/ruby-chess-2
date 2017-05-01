require_relative "Chess"

class ChessMove < Chess

  attr_reader :start_square, :end_square, :promotion

  def initialize(start_square, end_square, promotion)
    @start_square = start_square
    if !@start_square.is_a? Array
      raise ArgumentError.new "starting square must be of type Array"
    elsif !valid_move_square(@start_square)
      raise ArgumentError.new "invalid starting square"
    end

    @end_square = end_square
    if !@end_square.is_a? Array
      raise ArgumentError.new "ending square must be of type Array"
    elsif !valid_move_square(@end_square)
      raise ArgumentError.new "invalid ending square"
    end

    @promotion = promotion
    if !(@promotion.is_a? FalseClass) && !(@promotion.is_a? Integer)
      raise ArgumentError.new "promotion must be of type Integer or FalseClass"
    elsif !(@promotion.is_a? FalseClass) && !((2..5).include? @promotion)
      raise ArgumentError.new "promotion must be between 2 and 5"
    end
  end

  def to_s
    move = "#{((7 - @start_square[0]) + 97).chr}" +
      "#{@start_square[1] + 1}" +
      " #{((7 - @end_square[0]) + 97).chr}" +
      "#{@end_square[1] + 1}"
    if @promotion
      move = move + " promote to #{piece(@promotion)}"
    end
    return move
  end

  private

  def valid_move_square(move_square)
    move_square.length == 2 && move_square.all? { |i| i.is_a? Integer } && move_square.all? { |i| 0 <= i && i <= 7 }
  end
end
