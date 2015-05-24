require "csv"

class Connector
  TRAIN = "train_mock.csv"
  SPRAY = "spray_mock.csv"
  WEATHER = "weather_mock.csv"
  OUT = "out.csv"
  attr_accessor :train_file, :weather_file, :spray_file, :out_file

  def connect
    delete_output_contents
    @train_file = CSV.open(TRAIN, headers: true)
    @weather_file = CSV.open(WEATHER, headers: true)
    @spray_file = CSV.open(SPRAY, headers: true)
    @out_file = CSV.open(OUT, "wb")
    make_header
    add_train
  end

  def delete_output_contents
    File.open(OUT, 'w') {|file| file.truncate(0) }
  end

  def add_train
    CSV.read(TRAIN, headers: true).each do |line|
      line["Address"] = nil
      line["AddressNumberAndStreet"] = nil
      CSV.open(OUT, "ab") do |csv|
        new_line = line.to_csv
        new_line.delete("\n")
        csv_line = new_line + "," + connect_weather(line["Date"]).join(",")
        csv << csv_line.split(",")
      end
    end
  end

  def make_header
    train_headers = train_file.readline.headers
    weather_headers = weather_file.readline.headers
    spray_headers = spray_file.readline.headers

    multiple_weather_headers = 1.upto(122).flat_map do |x|
      weather_headers.map { |h| x.to_s + h }
    end

    multiple_spray_headers = 1.upto(30).flat_map do |x|
      spray_headers.map { |h| x.to_s + h }
    end

    CSV.open(OUT, "wb") do |csv|
      csv << train_headers + multiple_weather_headers + multiple_spray_headers
    end
  end

  def add_to_csv

  end

  def connect_weather(date)
    weather_file.rewind
    matched_dates = weather_file.map do |line|
      (line.to_csv.delete("\n")) if (Date.parse(date) - Date.parse(line["Date"])).abs <= 30
    end
    matched_dates.delete(nil)
    matched_dates
  end

  def connect_sprays(date)
    spray_file.rewind
  end

end

connector = Connector.new
connector.connect
