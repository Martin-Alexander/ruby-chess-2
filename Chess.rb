class Chess

  module ChessPieces
    def piece
      if !(self.is_a? Integer)
        raise ArgumentError.new "arguement must be of type Integer"
      elsif !((-6..-1).to_a + (1..6).to_a).include? self
        raise ArgumentError.new "integer #{self} is out of range"
      end

      case self.abs
        when 6 then "king"
        when 5 then "queen"
        when 4 then "rook"
        when 3 then "bishop"
        when 2 then "knight"
        when 1 then "pawn"
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

end
