class Move

  module ChessPieces
    def piece
      if !(self.is_a? Integer)
        raise ArgumentError.new "arguement must be of type Integer"
      elsif !((-6..-1).to_a + (0..6).to_a).include? self
        raise ArgumentError.new "integer #{self} is out of range"
      end

      case self.abs
        when 6 then "king"
        when 5 then "queen"
        when 4 then "rook"
        when 3 then "bishop"
        when 2 then "knight"
        when 1 then "pawn"
        when 0 then nil
      end
    end

    def color
      if self < 0
        "black"
      elsif self > 0
        "white"
      else
        nil
      end
    end
  end

  Fixnum.send(:include, ChessPieces)

  attr_reader :start_square, :end_square, :promotion, :in_bounds

  def initialize(start_square, end_square, params ={})
    @start_square = start_square
    @end_square = end_square
    @in_bounds = in_bounds?
    @promotion = params[:promotion] || 0
    @castling = params[:castling]
  end

  def to_s
    move = "#{(@start_square[1] + 97).chr}" +
      "#{8 - @start_square[0] }" +
      " #{(@end_square[1] + 97).chr}" +
      "#{8 - @end_square[0]}"
    if !@promotion.zero?
      move = move + " promote to #{@promotion.piece}"
    end
    return move
  end

  private

  def valid_move_square(move_square)
    move_square.length == 2 && move_square.all? { |i| i.is_a? Integer }
  end

  def in_bounds?
    @start_square[0] <= 7 &&
      @start_square[0] >= 0 &&
      @start_square[1] <= 7 &&
      @start_square[1] >= 0 &&
      @end_square[0] <= 7 &&
      @end_square[0] >= 0 &&
      @end_square[1] <= 7 &&
      @end_square[1] >= 0
  end
end
