# encoding: UTF-8

require 'pp'
require 'json'
require 'open-uri'
require 'uri'
require 'base64'

###############################################################################
# SETUP
###############################################################################

UPLOAD_SPOTIFY_IDS = true
NUM_THREADS = 20

Thread.abort_on_exception = true

@lock = Mutex.new
$stdout.sync = true

encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
    :universal_newline => true       # Always break lines with \n
}

text = File.open("PitchforkBestNewMusic.json", "r:UTF-8").read
json = JSON.parse(text)['results']

###############################################################################
# GET SPOTIFY TOKEN
###############################################################################

CLIENT_ID = "19b6fa16c893441f8aa82815931d7e78"
CLIENT_SECRET = "372341340e5c41ce950fffa989f08cb4"

code = Base64.strict_encode64("#{CLIENT_ID}:#{CLIENT_SECRET}")

response = JSON.parse(`curl -H "Authorization: Basic #{code}" -d grant_type=client_credentials https://accounts.spotify.com/api/token`)
ACCESS_TOKEN = response["access_token"]

###############################################################################
# RUN
###############################################################################

if UPLOAD_SPOTIFY_IDS then

	threads = (0...NUM_THREADS).map do |i|
		Thread.new do

			loop do

				###########################################
				# Get album object from json
				###########################################
				e = nil
				@lock.synchronize {
					if json != []
						e = json.pop()
					end
				}
				if e == nil then break end

				id = e["objectId"]
				album = e["album"]
				
				# Encode album name for curl
				if album.strip! == "" then next end
				ascii_album = album.encode(Encoding.find('ASCII'), encoding_options)
				encoded_album = URI.escape(ascii_album).gsub("&", "%26")

				pp "working on #{album} #{id}"

				###########################################
				# Search Spotify for album and get Spotify ID
				###########################################
				response = JSON.parse(`curl -H "Authorization: Bearer #{ACCESS_TOKEN}" -X GET "https://api.spotify.com/v1/search?q=album:#{encoded_album}&type=album&market=US"`.force_encoding('UTF-8'))

				if response["error"]
					pp response["error"]["message"]

					if response["error"]["message"] == "API rate limit exceeded"
						@lock.synchronize {
							json << e
						}
						sleep(60)
						redo
					else
						next
					end
				elsif (items = response["albums"]["items"]) == []
					pp "#{album} IS NOT IN SPOTIFY"
					next
				end

				# Store first search result's spotify id
				spotify_id = items[0]["id"]

				###########################################
				# Get albums tracklist from Spotify
				###########################################
				response = JSON.parse(`curl -H "Authorization: Bearer #{ACCESS_TOKEN}" -X GET "https://api.spotify.com/v1/albums/#{spotify_id}/tracks?"`.force_encoding('UTF-8'))

				if response["error"]
					pp response["error"]["message"]

					if response["error"]["message"] == "API rate limit exceeded"
						@lock.synchronize {
							json << e
						}
						sleep(60 * 2)
						redo
					else
						next
					end
				elsif (items = response["items"]) == []
					pp "NO TRACKS FROM SPOTIFY"
					next
				end

				# Store and prepare album track list
				tracks = response["items"].map { |e| e["name"] }.join("\n")

				tracks.gsub!("\n", "\\n")
				tracks.gsub!('"', '\u0022') # replace double quote with UTF-8 code
				
				###########################################
				# Update parse object with spotify id and track list
				###########################################
				response = `curl -X Put -H \"X-Parse-Application-Id: FP2mYhAXT4lL3J2ggpo6sIoRUCisS6F5vfRnbRFm\" -H \"X-Parse-REST-API-Key: Ce6VrAE8Wgx4IkDgUWLS4K9rEklnaH9hWLzhZ41U\" -H \"Content-Type: application/json; charset=utf-8\" -d "{ \\"spotify_id\\": \\"#{spotify_id}\\", \\"tracks\\": \\"#{tracks}\\" }" https://api.parse.com/1/classes/PitchforkBestNewMusic/#{id}`

				if response.include? "error"
					raise("ERROR for #{album}, #{response}")
				else
					pp response
				end

				###########################################
				# Break if no more album objects
				###########################################
				break if json == []

			end
		end
	end

	threads.each {|t| t.join}

end


