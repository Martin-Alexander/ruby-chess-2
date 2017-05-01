class Chess

  private

  def piece(int)
    if !(int.is_a? Integer)
      raise ArgumentError.new "arguement must be of type Integer"
    elsif !((-6..-1).to_a + (1..6).to_a).include? int
      raise ArgumentError.new "integer out of range"
    end

    case int.abs
      when 6 then "king"
      when 5 then "queen"
      when 4 then "rook"
      when 3 then "bishop"
      when 2 then "knight"
      when 1 then "pawn"
    end
  end
end
