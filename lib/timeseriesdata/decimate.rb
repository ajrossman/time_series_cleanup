require 'csv'
require 'date'
require 'redis'

module Timeseriesdata
  module Decimate
    def self.to_fifteen_minute_intervals(site_directory, datafile_directory, filename, processed_subdirectory_name, *points)
      puts 'entered Timeseries::Decimate'
	  # Convert data into regularly spaced interval data.  Timestamps are analyzed to determine
	  #  which 15 minute interval they belong to (1:00:01 to 1:15:00 are all included in 1:15:00 interval). 
	  #  The data are process by grouping all data into 15 minute intervals and then calculating average, 
	  #  minimum, maximum and number of measurements included in each interval.  The output data are formatted
	  #  Timestamp, average, min, max, # of measurements

  	  # Method utilizes sorted sets in Redis key-value store.  The epoch seconds for each interval is used as a key and
	  #  lists are created for each interval.  Data for each timestamp are pushed to the key that 
	  #  corresponds to interval it belongs to.  After processing data, all data are dumped from each key
	  #  and processed into average, min, max and count.  The fifteen-minute interval data are saved to a file in 
	  #  new subfolder called 'fifteen_minute' with '_15' appended to the end of the filename.

	  # Method checks to see if value is non-numeric (Yes, True, No, False) and converts to numeric value if true
	  #  Yes/True = 1, No/False = 0

	  # TODO add intervals with no data to make complete data sets 
$redis = Redis.new(:host => 'localhost', :port => 6379, :db => 2)

	  minute_interval = 15  # This is the number of minutes in each interval
	  timestamp_column = 0  # This is the column with timestamp data

	  # create db => 3
	  redis_sorter = Redis.new(:db => 3)
	  # clean out redis db to start
	  redis_sorter.FLUSHDB

	  label_measurement = Array.new
	  column_measurement = Array.new
	  header = Array.new
	  processed_data = Array.new

      filename_with_location = Rails.root.join("public/site_data/",site_directory,datafile_directory,filename)
	  
      puts "Decimating data in #{filename_with_location}"
	  
	   # parse file line by line
	  CSV.foreach("#{filename_with_location}", headers: true) do |row|
	  	
	    #timestamp = DateTime.strptime(row[0]+row[1], '%Y/%m/%d %H:%M:%S').in_time_zone('Eastern Time (US & Canada)')
	    timestamp = Time.local.parse("#{row[0]} #{row[1]}")
	    puts "#{timestamp} in #{timestamp.zone}"

	    es = timestamp.to_time.to_i - 60  # subtract 1 minute so :15 is in :15 interval and not :30

	    # determine 15 minute interval 
	    es_interval = es / (minute_interval * 60) + 1
	    interval = Time.at(es_interval * minute_interval * 60).to_datetime

	    points.flatten.each do |point|
          point_name = point.keys.first
          point_column = point[point_name].to_i

          # check to see if non-numeric value, and if so, convert to numerica
          if row[point_column].is_a? Fixnum
            value = row[point_column]
          elsif row[point_column].downcase == 'yes'
            value = 1.0
          elsif row[point_column].downcase == 'true'
            value = 1.0
          elsif row[point_column].downcase =='no'
            value = 0.0
          elsif row[point_column].downcase =='false'
            value = 0.0
          else
            value = -999
          end

	      # add es_interval to set -> only adds unique values, so this will save only keys 
	      redis_sorter.SADD('es_intervals',es_interval)

	      # push data to list of appropriate key
	      redis_sorter.LPUSH("#{es_interval}:#{point_name}",row[point_column]) 
	    end
	  end

      # Make new directory for processed data
      Dir.chdir(Rails.root.join("public/site_data/#{site_directory}/#{datafile_directory}"))

	  # Write data from Redis to file
	  CSV.open("#{processed_subdirectory_name}/#{File.basename(filename,'.csv')}_15.csv",'wb') do |csv|
	    # headers
	    header[0] = 'timestamp'
	    points.flatten.each do |point|
	      header.push("#{point.keys.first}_average","#{point.keys.first}_min","#{point.keys.first}_max","#{point.keys.first}_count")
	    end
	    csv << header
	    # get all keys - probably should sort

	    es_intervals_array = redis_sorter.SMEMBERS('es_intervals')

	    # loop for each key for all measurements
	    es_intervals_array.each do |es_interval|
	      processed_data = []
	      interval = Time.at(es_interval.to_i * minute_interval * 60).to_datetime
	      processed_data[0] = interval
	      points.flatten.each do |point|
	        arr = redis_sorter.LRANGE("#{es_interval}:#{point.keys.first}",0,-1)
		    arrf = arr.collect{|i| i.to_f}
		    array_average = arrf.inject { |sum, el| sum + el } / arrf.size
		    processed_data.push(array_average, arr.min, arr.max, arr.count)
	      end
	      csv << processed_data
	    end
	  end
    end
  end
end
