require 'HTTParty'
require 'byebug'
require 'csv'

class FareCalculator
	
	
	def initialize
		@google_api_key = "AIzaSyDWT2WuoqtHWnbRWMPNm5mLLJiIn3ROhjk"
		@url = "https://www.googleapis.com/qpxExpress/v1/trips/search?key=#{@google_api_key}"
	end 

	def fare(date, origin, destination)
		departure_date = date.strftime("%Y-%m-%d")
		return_date = (date + 2).strftime("%Y-%m-%d")
		api_request = {
		  "request"=> {
		    "slice"=> [
		      {
		        "origin"=> origin,
		        "destination"=> destination,
		        "date"=> departure_date,
		        "permittedDepartureTime"=> {
		          "earliestTime"=> "18:00"
		        }
		      },
		      {
		        "origin"=> destination,
		        "destination"=> origin,
		        "date"=> return_date,
		        "permittedDepartureTime"=> {
		          "earliestTime"=> "15:00"
		        }
		      }
		    ],
		    "passengers"=> {
		      "adultCount"=> 1,
		      "infantInLapCount"=> 0,
		      "infantInSeatCount"=> 0,
		      "childCount"=> 0,
		      "seniorCount"=> 0
		    },
		    "solutions"=> 5,
		    "refundable"=> false
		  }
		}
		begin 
			req = HTTParty.post(@url, body: api_request.to_json, headers: { 'Content-Type' => 'application/json' })
			cheapest_flight_fare = req["trips"]['tripOption'][0]["saleTotal"]
		rescue 
			byebug
			puts "test"
		end 
	end 
end 

departure_cities = ["BOS", "NYC", "CHI", "WAS"]
destination_cities = departure_cities
city_pairs = Array.new

departure_cities.each do |departure_city|
	destination_cities.each do |destination_city|
		city_pairs.push([destination_city, departure_city]) unless destination_city == departure_city
	end 
end 

CSV.open("flight_fares.csv", "a") do |csv|
	city_pairs.each do |departure_city, arrival_city|
		fare_calculator = FareCalculator.new
		date = Date.new(2016,4,29)
		last_date = Date.new(2016,8,8)
		while date < last_date	
			price = fare_calculator.fare(date, departure_city, arrival_city)
			csv << [departure_city, arrival_city, date, price]
			date += 7
		end
	end 
end 