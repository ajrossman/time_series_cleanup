require 'csv'
require 'pry'
require 'date'

module TimeSeriesCleanup

  # Generates daily averages from irregular courser grained data in csv files and outputs as hash of arrays  
  module DailyAverage

  	def self.format_csv_into_matrix_with_start_end_difference_rows(datafile_directory, filename)
      matrix_with_start_end_difference_rows = []
      interval_start_date = Date.today
      interval_start_value = 0
      date_and_values = CSV.read("#{datafile_directory}/#{filename}")
      date_and_values.each_with_index do |row_data,row|
      	if row == 0
          # skip header
        elsif row == 1
          # no calculations yet because we only have start date
      	  interval_start_date = Date.strptime(row_data[0], '%m/%d/%y')
      	  interval_start_value = row_data[1].to_f
      	else
      	  # start calculations
      	  interval_end_date = Date.strptime(row_data[0], '%m/%d/%y')
      	  interval_end_value = row_data[1].to_f
      	  value_difference = interval_end_value - interval_start_value
      	  matrix_with_start_end_difference_rows[row - 2] = [interval_start_date, interval_end_date, value_difference]
      	  interval_start_date = interval_end_date
      	  interval_start_value = interval_end_value
      	end
        
      end

      matrix_with_start_end_difference_rows
  	
  	end

  	def self.days_in_between(interval_start_date, interval_end_date)

  	end

  end
  
end
