require_relative "Chess"
require_relative "ChessMove"
require "byebug"

class ChessBoard < Chess

  attr_reader :ply, :board, :white_to_move, :castling, :en_passant

  def initialize(params = {})
    @ply = params[:ply] || 0
    if !@ply.is_a? Integer
      raise ArgumentError.new "ply must be of type Integer"
    elsif @ply < 0
      raise ArgumentError.new "invalid ply must be positive integer"
    end

    @board = params[:board] || standard_board_setup
    if !@board.is_a? Array
      raise ArgumentError.new "board must be of type Array"
    elsif !valid_pieces(@board)
      raise ArgumentError.new "invalid board"
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

  def legal_moves(rank, file)
    case @board[rank][file].abs
      when 1 then naive_pawn_moves(rank, file)
      when 2 then naive_knight_moves(rank, file)
      when 4 then naive_rook_moves(rank, file)
      when 6 then naive_king_moves(rank, file)
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

  def naive_pawn_moves(rank, file)
    output = []
    piece = @board[rank][file]
    v_direction = piece > 0 ? -1 : 1

    if @board[rank + 1 * v_direction][file].zero? &&
      output << ChessMove.new([rank, file], [rank + 1 * v_direction, file])
      if @board[rank + 2 * v_direction][file].zero? &&
        ((rank == 1 && color(piece) == "black") || (rank == 6 && color(piece) == "white"))
        output << ChessMove.new([rank, file], [rank + 2 * v_direction, file])
      end
    end
    if !(@board[rank + 1 * v_direction][file - 1]).zero? &&
      color(piece) != color(@board[rank + 1 * v_direction][file - 1])
      output << ChessMove.new([rank, file], [rank + 1 * v_direction, file - 1])
    end
    if !(@board[rank + 1 * v_direction][file + 1]).zero? &&
      color(piece) != color(@board[rank + 1 * v_direction][file + 1])
      output << ChessMove.new([rank, file], [rank + 1 * v_direction, file + 1])
    end
    remove_out_of_bounds(output)
  end

  def naive_king_moves(rank, file)
    output = []
    piece = @board[rank][file]

    [-1, 0, 1].each do |rank_inc|
      [-1, 0, 1].each do |file_inc|
        if !(rank_inc.zero? && file_inc.zero?) &&
          !(color(piece) == color(@board[rank + rank_inc][file + file_inc]))
          output << ChessMove.new([rank, file], [rank + rank_inc, file + file_inc])
        end
      end
    end
    remove_out_of_bounds(output)
  end

  def naive_knight_moves(rank, file)
    output = []
    piece = @board[rank][file]

    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]].each do |i|
      if (@board[rank + i[0]][file + i[1]].zero? ||
        color(piece) != color(@board[rank + i[0]][file + i[1]]))
        output << ChessMove.new([rank, file], [rank + i[0], file + i[1]])
      end
    end
    remove_out_of_bounds(output)
  end

  def naive_rook_moves(rank, file)
    output = []
    piece = @board[rank][file]

    (1..rank).each do |rank_inc|
      if @board[rank - rank_inc][file].zero?
        output << ChessMove.new([rank, file], [rank - rank_inc, file])
      elsif color(@board[rank - rank_inc][file]) != color(piece)
        output << ChessMove.new([rank, file], [rank - rank_inc, file])
        break
      else
        break
      end
    end

    (1..7 - rank).each do |rank_inc|
      if @board[rank + rank_inc][file].zero?
        output << ChessMove.new([rank, file], [rank + rank_inc, file])
      elsif color(@board[rank + rank_inc][file]) != color(piece)
        output << ChessMove.new([rank, file], [rank + rank_inc, file])
        break
      else
        break
      end
    end

    (1..file).each do |file_inc|
      if @board[rank][file - file_inc].zero?
        output << ChessMove.new([rank, file], [rank, file - file_inc])
      elsif color(@board[rank][file - file_inc]) != color(piece)
        output << ChessMove.new([rank, file], [rank, file - file_inc])
        break
      else
        break
      end
    end

    (1..7 - file).each do |file_inc|
      if @board[rank][file + file_inc].zero?
        output << ChessMove.new([rank, file], [rank, file + file_inc])
      elsif color(@board[rank][file + file_inc]) != color(piece)
        output << ChessMove.new([rank, file], [rank, file + file_inc])
        break
      else
        break
      end
    end
    remove_out_of_bounds(output)
  end

  def remove_out_of_bounds(output)
    output.select { |i| i.in_bounds }
  end
end
