# encoding: UTF-8

require 'nokogiri'
require 'pp'
require 'json'
require 'open-uri'

###############################################################################
# SETUP
###############################################################################

FIX_PITCHFORK_NAMES = true

text = File.open("PitchforkBestNewMusic.json", "r:UTF-8").read
json = JSON.parse(text)['results']

###############################################################################
# RUN
###############################################################################

if FIX_PITCHFORK_NAMES then
	json.map { |e| 

		url = e['url']
		id = e['objectId']

		pp "working on #{url} #{id}"

		###################################################
		# Get artist and album name from html
		###################################################
		doc = Nokogiri::HTML(open(url))
		node = doc.css("div.info")
		artist = node.css("h1")[0].text
		album = node.css("h2")[0].text

		###################################################
		# Update parse object with names
		###################################################
		response = `curl -X Put -H \"X-Parse-Application-Id: FP2mYhAXT4lL3J2ggpo6sIoRUCisS6F5vfRnbRFm\" -H \"X-Parse-REST-API-Key: Ce6VrAE8Wgx4IkDgUWLS4K9rEklnaH9hWLzhZ41U\" -H \"Content-Type: application/json; charset=utf-8\" -d "{ \\"album\\": \\"#{album}\\", \\"artist\\": \\"#{artist}\\" }" https://api.parse.com/1/classes/PitchforkBestNewMusic/#{id}`

		pp response
	}
end
