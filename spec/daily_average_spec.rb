require 'timeseriesdata'
require 'csv'
require 'date'


describe Timeseriesdata::DailyAverage do 
  
  before :all do
  	START_DATE = Date.today
  	END_DATE = Date.today - 10
    TEST_FILE_DIRECTORY = 'spec/support/test_data'
    TEST_FILE = 'test_data.csv'
  end

  it 'should format csv file into matrix for processing with start, end and value rows' do 
    test_matrix = Timeseriesdata::DailyAverage.format_csv_into_matrix_with_start_end_difference_rows(TEST_FILE_DIRECTORY, TEST_FILE)
    test_matrix[0][0].should eql(Date.strptime('1/20/12', '%m/%d/%y'))
    test_matrix[0][1].should eql(Date.strptime('3/20/12', '%m/%d/%y'))
    test_matrix[0][2].should eql(144783.51)
    test_matrix[3][0].should eql(Date.strptime('9/20/12', '%m/%d/%y'))
    test_matrix[3][1].should eql(Date.strptime('12/19/12', '%m/%d/%y'))
    test_matrix[3][2].should eql(182764.68)
  end

  # it 'should find the right number of days for first inteval in test csv file' do
  # 	TimeSeriesCleanup::DailyAverage.days_in_between(START_DATE, END_DATE).should eql(10) 
  # end

  it 'should calculate the right average value for each day in the interval' do
  	# TimeSeriesCleanup::DailyAverage.daily_average(TEST_FILE,1,2).should eql(2413.0585)
  end

  it 'should populate the last 11 days of January with average value' do
    
  end

  it 'should not populate the first 20 days of January with average value' do 
  end

end

