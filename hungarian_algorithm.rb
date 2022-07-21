
class HungarianAlgorithm
  def initialize()
    # @matrix = Matrix[*array_2d]
    50.times do
      n = 50
      r = rand(50)
      arr1 = (r).times.map{ rand(50..100) }
      arr2 = (n-r).times.map{ 10000 }
      puts "[ #{arr1.join(', ')}, #{arr2.join(', ')} ],"
    end
  end

  def process
    minimize_rows
    draw_lines
    assign and return if enough_lines?

    minimize_columns
    draw_lines
    assign and return if enough_lines?

    loop do
      minimize_uncovered_values
      draw_lines
      break if enough_lines?
    end

    assign
  end

  private

  attr_accessor :matrix

  def minimize_rows
    puts 'Step 1: Minimizing rows'
    matrix.row_vectors.each_with_index do |row, i|
      min = row.min
      next if min.zero?

      row.each_with_index { |cell, j| matrix[i, j] = cell - min }
    end
  end

  # Step 2 : Star all zero which are not on a row/coulmn with another already starred zero
  def draw_lines
    puts 'Step 2/4/6: Draw minimum number of lines to cover all zeros'
    zero_indexes = []
    @lines = { rows: [], columns: [] }

    on_each_cell { |cell, i, j| zero_indexes << [i, j] if cell.zero? }

    loop do
      row_index_hash = Hash.new(0)
      col_index_hash = Hash.new(0)

      zero_indexes.each do |i, j|
        row_index_hash[i] += 1
        col_index_hash[j] += 1
      end

      if row_index_hash.values.max > col_index_hash.values.max
        index = row_index_hash.max_by { |k,v| v }[0]
        @lines[:rows] << index
        zero_indexes.delete_if { |i, j| i == index }
      else
        index = col_index_hash.max_by { |k,v| v }[0]
        @lines[:columns] << index
        zero_indexes.delete_if{ |i, j| j == index }
      end

      break if zero_indexes.blank?
    end
  end

  def minimize_columns
    puts 'Step 3: If a column does not have a 0, subtract the lowest value in the column from every value in that column'

    matrix.column_vectors.each_with_index do |column, i|

      min = column.min
      next if min.zero?

      column.each_with_index { |cell, j| matrix[j, i] = cell - min }
    end
  end

  def minimize_uncovered_values
    puts "\nStep 5: Identify the smallest value covered by not covered by any of the line"
    puts "add it to any value covered by two lines and subtract it from all uncovered values\n"
    min = min_uncovered_value

    @lines[:rows].each do |i|
      @lines[:columns].each do |j|
        matrix[i, j] = matrix[i, j] + min
      end
    end

    on_each_cell do |cell, i, j|
      next if @lines[:rows].include?(i) || @lines[:columns].include?(j)

      matrix[i, j] = matrix[i, j] - min
    end
  end

  def assign
    assignment = matrix.row_vectors.each_with_index.map do |row, i|
      row.each_with_index.map { |cell, j| j if cell.zero? }.compact
      # row.sort.first(10)
    end

    assignment.each_with_index{ |arr, i| puts "#{i} => #{arr.join(', ')}" }

    assignment
  end

  def min_uncovered_value
    min = matrix.max

    on_each_cell do |cell, i, j|
      next if  @lines[:rows].include?(i) || @lines[:columns].include?(j)

      min = cell if cell < min
    end

    min
  end

  def enough_lines?
    @lines.values.map(&:count).sum >= matrix_size
  end

  def display
    matrix.row_vectors.map { |row| puts row }
    puts "\n"
  end

  def validate
    raise NotImplementedError unless matrix.square?
  end

  def on_each_cell
    @matrix.each_with_index { |cell, i, j| yield(cell, i, j) }
  end

  def reset_indexes_hash
    @row_index_hash = Hash.new(0)
    @col_index_hash = Hash.new(0)
  end

  def matrix_size
    @matrix_size ||= matrix.row_size
  end

end
