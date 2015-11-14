# encoding: UTF-8

require 'pp'
require 'json'
require 'nokogiri'
require 'open-uri'

text = File.open("PitchforkBestNewMusic.json", "r:UTF-8").read
json = JSON.parse(text)['results']
ids = []

DOWNLOAD_ART = false
UPLOAD_TO_PARSE = true

if DOWNLOAD_ART then
	json.map { |e| 

		url = e['url']

		doc = Nokogiri::HTML(open(url))
		picurl = doc.css("div.artwork img")[0].attr('src')

		# list_picurl = picurl.gsub("homepage_large","list")
		filename = "./AlbumArt/large/#{e['objectId']}_large.jpg"

		ids << e['objectId']
		
		File.open(filename, 'wb') do |fo|
	  		fo.write open(picurl).read 
		end

	}
end

if UPLOAD_TO_PARSE then
	json.map { |e|

		id = e['objectId']

		filename = id + "_large.jpg"

		output = `curl -X POST -H \"X-Parse-Application-Id: FP2mYhAXT4lL3J2ggpo6sIoRUCisS6F5vfRnbRFm\" -H \"X-Parse-REST-API-Key: Ce6VrAE8Wgx4IkDgUWLS4K9rEklnaH9hWLzhZ41U\" -H \"Content-Type: image/jpeg\" --data-binary '@./AlbumArt/large/#{filename}' https://api.parse.com/1/files/#{filename}`

		name = JSON.parse(output)["name"]

		output = `curl -X Put -H \"X-Parse-Application-Id: FP2mYhAXT4lL3J2ggpo6sIoRUCisS6F5vfRnbRFm\" -H \"X-Parse-REST-API-Key: Ce6VrAE8Wgx4IkDgUWLS4K9rEklnaH9hWLzhZ41U\" -H \"Content-Type: application/json\" -d '{ \"album_art_large\": {\"name\": \"#{name}\", \"__type\": \"File\"}}' https://api.parse.com/1/classes/PitchforkBestNewMusic/#{id}`

	}
end
