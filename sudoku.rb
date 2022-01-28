# require 'pry'
class Sudoku
  # numbers should be: 2D array of 9*9 or 16*16 etc
  # numbers should be: 1D array of 81 or 256 etc
  def initialize(numbers)
    @counter = 0
    # @size = size
    # @square_size = Math.sqrt(@size).to_i
    single_d_array = numbers.flatten
    @square_size = (single_d_array.size ** (1.0/4)).to_i
    raise "invalid size (should be something like 9 or 16)" unless @square_size ** 4 == single_d_array.size
    @size = @square_size * @square_size
    @aa = single_d_array.each_slice(@size).to_a
  end

  def solve
    catch :done do
      magic(0,0)
      # means there's no solution
      puts 'No Solution Found.'
      # show_board#(mode: :simple)
      return self
    end

    puts 'Solution Found:'
    self
  end

  def show_board(mode: :borders2, sep: ' ')
    case mode
    when :borders1 then print_borders1(sep: sep)
    when :borders2 then print_borders2(sep: sep)
    when :simple then print_simple(sep: sep)
    end
  end

  private

  def magic(row,col)
    # puts "magic1: #{row};#{col}"
    row_to_use,col_to_use = adujst_row_col(row,col)
    # puts "magic2: #{row_to_use};#{col_to_use}"

    # done:
    if row_to_use == @size
      throw :done
    end

    # already has num here
    if @aa[row_to_use][col_to_use]
      magic(row_to_use,col_to_use+1)
      return
    end

    # regular1
    for current_num in 1..@size do
      # seting temp insert
      # binding.pry if current_num == 9
      @aa[row_to_use][col_to_use] = current_num
      if valid_insert?(row_to_use,col_to_use)
        # puts "#{@counter +=1;@counter} valid_insert (#{current_num}), at #{row_to_use};#{col_to_use}"
        exit if @counter > 99930 # infinite loop much?
        magic(row_to_use,col_to_use+1)
      else
        # puts "invalid #{current_num} at #{row_to_use};#{col_to_use}"
        next
      end
    end
    # reseting temp insert
    @aa[row_to_use][col_to_use] = nil

  end

  def adujst_row_col(row,col)
    if col == @size
      [row+1,0]
    else
      [row,col]
    end
  end

  def valid_insert?(entered_row,entered_col)
    num_to_check = @aa[entered_row][entered_col]
    # binding.pry if num_to_check == 9

    # check row
    return false if (0...@size).count{|col| num_to_check == @aa[entered_row][col]} > 1

    # check col
    return false if (0...@size).count{|row| num_to_check == @aa[row][entered_col]} > 1

    # check square
    counter = 0
    for row_offset in 0...@square_size
      for col_offset in 0...@square_size
        # puts "(offsets: #{row_offset} #{col_offset})#{(entered_row/@square_size)*@square_size+row_offset}:#{(entered_col/@square_size)*@square_size+col_offset} #{@aa[entered_row/@square_size+row_offset][entered_col/@square_size+col_offset]}"
        counter += 1 if @aa[(entered_row/@square_size)*@square_size+row_offset][(entered_col/@square_size)*@square_size+col_offset] == num_to_check
      end
    end
    return false if counter > 1

    true
  end

  def print_simple(sep: ' ', missing: 'x')
    for row in 0...@size do
      puts @aa[row].map{|val| val || missing}.join(' ')
    end
  end

  def print_borders1(sep: ' ', missing: 'x')
    puts '-'*(@size*2+1)
    for row in 0...@size do
      for col in 0...@size do
        print '|' if col == 0
        print "#{@aa[row][col] || missing}#{(col % @square_size == @square_size-1) ? '|' : sep}"
      end
      puts ''
      if row % @square_size == @square_size-1
        puts '-'*(@size*2+1)
      end
    end
  end

  def print_borders2(sep: ' ', missing: 'x')
    for row in 0...@size do
      for col in 0...@size do
        # print "#{@aa[row][col] || missing}#{(col % @square_size == @square_size-1) ? '|' : sep unless col == @size-1}"
        if col % @square_size == @square_size-1
          suffix = " |"
        end unless col == @size-1
        print "#{@aa[row][col]}#{suffix}#{sep unless col == @size-1}"; suffix = nil
      end
      puts ''
      if row % @square_size == @square_size-1
        puts '-'*(@size*2+@square_size*1)
      end unless row == @size - 1
    end
  end

  # def valid_row?
  #   # code
  # end
end

valid = [
  [nil,4  ,nil,  nil,nil,1  ,  nil,nil,nil],
  [5  ,nil,nil,  nil,4  ,nil,  nil,1  ,3  ],
  [1  ,nil,6  ,  8  ,nil,7  ,  nil,nil,nil],

  [nil,6  ,1  ,  nil,5  ,3  ,  nil,nil,nil],
  [nil,nil,nil,  2  ,nil,nil,  nil,6  ,9  ],
  [3  ,nil,8  ,  nil,9  ,nil,  nil,7  ,nil],

  [2  ,nil,nil,  nil,nil,nil,  7  ,nil,nil],
  [7  ,nil,3  ,  9  ,nil,nil,  4  ,5  ,1  ],
  [nil,nil,nil,  nil,nil,4  ,  nil,nil,nil],
]
valid2 = [
  [7,2,6,4,9,3,8,1,5], # 0
  [3,1,5,7,2,8,9,4,6], # 1
  [4,8,9,6,5,1,2,3,7], # 2
  [8,5,2,1,4,7,6,9,3], # 3
  [6,7,3,9,8,5,1,2,4], # 4
  [9,4,1,3,6,2,7,5,8], # 5
  [1,9,4,8,3,6,5,7,2], # 6
  # # [5,6,7,2,1,4,3,8,9], # 7
  [5,6,7,2,1,4,3,8,nil], # 7;8 (9)
  # # [2,3,8,5,7,9,4,6,1], # 8
  [2,3,8,5,7,9,4,nil,nil], #8;7 (6), 8;8 (1)
]

invalid = [
  [nil,4  ,nil,  nil,nil,1  ,  nil,nil,nil],
  [5  ,nil,nil,  nil,4  ,nil,  nil,1  ,3  ],
  [1  ,nil,6  ,  8  ,nil,7  ,  nil,nil,nil],

  [nil,6  ,1  ,  nil,5  ,3  ,  nil,nil,nil],
  [nil,nil,nil,  2  ,nil,nil,  nil,6  ,9  ],
  [3  ,nil,8  ,  nil,9  ,nil,  nil,7  ,nil],

  [2  ,nil,nil,  nil,nil,nil,  7  ,5,nil], # invalid row, 5 should not be there
  [7  ,nil,3  ,  9  ,nil,nil,  4  ,5  ,1  ],
  [nil,nil,nil,  nil,nil,4  ,  nil,nil,nil],
]
complete = [
  [7,2,6,4,9,3,8,1,5], # 0
  [3,1,5,7,2,8,9,4,6], # 1
  [4,8,9,6,5,1,2,3,7], # 2
  [8,5,2,1,4,7,6,9,3], # 3
  [6,7,3,9,8,5,1,2,4], # 4
  [9,4,1,3,6,2,7,5,8], # 5
  [1,9,4,8,3,6,5,7,2], # 6
  [5,6,7,2,1,4,3,8,9], # 7
  [2,3,8,5,7,9,4,6,1], # 8
]

Sudoku.new(valid).solve.show_board
Sudoku.new(valid2).solve.show_board(mode: :borders1)
Sudoku.new(invalid).solve.show_board(mode: :simple)
Sudoku.new(complete).solve.show_board
