require "csv"

class Connector
  TRAIN = "train_mock.csv"
  SPRAY = "spray_mock.csv"
  WEATHER = "weather_mock.csv"
  OUT = "out.csv"
  LAT_CHANGE = 0.0435
  LON_CHANGE = 0.0566
  attr_accessor :train_file, :weather_file, :spray_file, :out_file

  def connect
    delete_output_contents
    @train_file = CSV.open(TRAIN, headers: true)
    @weather_file = CSV.open(WEATHER, headers: true)
    @spray_file = CSV.open(SPRAY, headers: true)
    @out_file = CSV.open(OUT, "wb")
    make_header
    combine_data
  end

  def delete_output_contents
    File.open(OUT, 'w') {|file| file.truncate(0) }
  end

  def combine_data
    CSV.read(TRAIN, headers: true).each do |line|
      line["Address"] = nil
      line["AddressNumberAndStreet"] = nil
      CSV.open(OUT, "ab") do |csv|
        new_line = line.to_csv
        new_line.delete("\n")
        date = line["Date"]
        lat = line["Latitude"]
        lon = line["Longitude"]
        csv_line = new_line + "," + connect_weather(date).join(",") + "," + connect_sprays(date, lat, lon).join(",")
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

  def connect_weather(date)
    weather_file.rewind
    matched_entries = weather_file.map do |line|
      line.to_csv.delete("\n") if (Date.parse(date) - Date.parse(line["Date"])).abs <= 30
    end
    matched_entries.delete(nil)
    matched_entries
  end

  def bounded?(test, against, day_diff)
    against = against.map { |x| x.to_f }
    mosquito_travel_x = day_diff.to_i * LAT_CHANGE
    mosquito_travel_y = day_diff.to_i * LON_CHANGE
    bounds_x = [against[0] + mosquito_travel_x, against[0] - mosquito_travel_x]
    bounds_y = [against[1] + mosquito_travel_y, against[1] - mosquito_travel_y]
    p test, against, day_diff.to_i if (test[0] >= bounds_x[0] || test[0] <= bounds_x[1]) && (test[1] >= bounds_y[0] || test[1] <= bounds_y[1])
  end

  def connect_sprays(date, lat, lon)
    spray_file.rewind
    matched_entries = spray_file.map do |line|
      spray_lat = line["Latitude"].to_f
      spray_lon = line["Longitude"].to_f
      day_diff = Date.parse(date) - Date.parse(line["Date"])
      if day_diff <= 30 && day_diff >= 0
        line.to_csv.delete("\n") if bounded?([spray_lat, spray_lon], [lat, lon], day_diff)
      end
    end
    matched_entries.delete(nil)
    matched_entries
  end

end

connector = Connector.new
connector.connect
