require "csv"

class Connector
  TRAIN = "train_mock.csv"
  SPRAY = "spray_mock.csv"
  WEATHER = "weather_mock.csv"
  OUT = "out.csv"
  attr_accessor :train_file, :weather_file, :spray_file, :out_file
  #HEADERS =


  def connect
    delete_output_contents
    @train_file = CSV.open(TRAIN, headers: true)
    @weather_file = CSV.open(WEATHER, headers: true)
    @spray_file = CSV.open(SPRAY, headers: true)
    @out_file = CSV.open(OUT, "wb")
    make_header

    #repository_file.rewind
    #repo_objects = repository_file.map do |line|
    #new_repo_object = class_name.new(self)
    #repository_headers.each {|h| new_repo_object.info[h] = line[h]}
    #new_repo_object
    #end
    #connect_weather
    #connect_sprays
  end

  def delete_output_contents
    File.open(OUT, 'w') {|file| file.truncate(0) }
  end

  def make_header
    train_headers = train_file.readline.headers
    weather_headers = weather_file.readline.headers
    spray_headers = spray_file.readline.headers

    multiple_weather_headers = 1.upto(120).flat_map do |x|
      weather_headers.map { |h| x.to_s + h }
    end

    multiple_spray_headers = 1.upto(30).flat_map do |x|
      spray_headers.map { |h| x.to_s + h }
    end

    out_file do |csv|
      csv << train_headers + multiple_weather_headers + multiple_spray_headers
    end
  end

  def add_to_csv

  end

  def connect_weather
    CSV.open(OUT, "wb") do |csv|
    end
  end

  def connect_sprays

  end

end

connector = Connector.new
connector.connect
