require_relative "Chess"

class ChessBoard < Chess

  attr_reader :ply, :pieces, :white_to_move, :castling, :en_passant

  def initialize(params = {})
    @ply = params[:ply] || 0
    if !@ply.is_a? Integer
      raise ArgumentError.new "ply must be of type Integer"
    elsif @ply < 0
      raise ArgumentError.new "invalid ply must be positive integer"
    end

    @pieces = params[:pieces] || standard_board_setup
    if !@pieces.is_a? Array
      raise ArgumentError.new "pieces must be of type Array"
    elsif !valid_pieces(@pieces)
      raise ArgumentError.new "invalid pieces"
    end

    @white_to_move = params[:white_to_move] || true
    raise ArgumentError.new "white_to_move must be a boolean" unless !!@white_to_move == @white_to_move

    @castling = params[:castling] || { white_king: true, white_queen: true, black_king: true, black_queen: true }
    if !@castling.is_a? Hash
      raise ArgumentError.new "castling must be of type Hash"
    elsif !valid_castling_hash(@castling)
      raise ArgumentError.new "invalid castling"
    end

    @en_passant = params[:en_passant] || [[0, 0], [0, 0]]
    if !@en_passant.is_a? Array
      raise ArgumentError.new "en_passant must be of type Array"
    elsif !valid_en_passant(@en_passant)
      raise ArgumentError.new "invalid en_passant"
      # TODO: Make more robust en passant validation using game logic
    end
  end

  private

  def valid_pieces(pieces_array)
    pieces_array.length == 8 && pieces_array.all? { |i| i.length == 8 }
  end

  def valid_castling_hash(castling_hash)
    castling_hash.length == 4 &&
    !!castling_hash[:white_king] == castling_hash[:white_king] &&
    !!castling_hash[:white_queen] == castling_hash[:white_queen] &&
    !!castling_hash[:black_king] == castling_hash[:black_king] &&
    !!castling_hash[:black_queen] == castling_hash[:black_queen]
  end

  def valid_en_passant(en_passant_array)
    en_passant_array.length == 2 && en_passant_array.all? { |i| i.length == 2}
    # TODO: Make more robust en passant validation using game logic
  end

  def standard_board_setup
    [
      [-4, -2, -3, -5, -6, -3, -2, -4],
      [-1, -1, -1, -1, -1, -1, -1, -1],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [4, 2, 3, 5, 6, 3, 2, 4]
    ]
  end
end
