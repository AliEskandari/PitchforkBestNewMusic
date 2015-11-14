# encoding: UTF-8

require 'pp'
require 'json'
require 'nokogiri'
require 'open-uri'

text = File.open("PitchforkBestNewMusic.json", "r:UTF-8").read
json = JSON.parse(text)['results']
ids = []

DOWNLOAD_ARTICLE_TEXT = true

if DOWNLOAD_ARTICLE_TEXT then
	json.map { |e| 

		url = e['url']
		id = e['objectId']

		pp "working on #{url} #{id}"

		doc = Nokogiri::HTML(open(url))
		article_text = doc.css("div.editorial p").map{ |e| e.text.strip }.join("\\n")

		article_text.gsub!("'","")
		article_text.gsub!('"', '\\\\"')

		output = `curl -X Put -H \"X-Parse-Application-Id: FP2mYhAXT4lL3J2ggpo6sIoRUCisS6F5vfRnbRFm\" -H \"X-Parse-REST-API-Key: Ce6VrAE8Wgx4IkDgUWLS4K9rEklnaH9hWLzhZ41U\" -H \"Content-Type: application/json; charset=utf-8\" -d '{ \"article_text\": \"#{article_text}\"}' https://api.parse.com/1/classes/PitchforkBestNewMusic/#{id}`
		
		if output.include?("error") then
			pp url
		end

		pp output

	}
end

abort

NUM_THREADS = 10

threads = (0...NUM_THREADS).map do |i|
    Thread.new do

    	while json do

	    	e = json.pop()

	    	url = e['url']
			id = e['objectId']

			pp "working on #{url} #{id}"

			doc = Nokogiri::HTML(open(url))
			article_text = doc.css("div.editorial").text

			article_text = article_text[1..-1]
			article_text.gsub!("'","")
			article_text.gsub!('"', '\\\\"')
			

			output = `curl -X Put -H \"X-Parse-Application-Id: FP2mYhAXT4lL3J2ggpo6sIoRUCisS6F5vfRnbRFm\" -H \"X-Parse-REST-API-Key: Ce6VrAE8Wgx4IkDgUWLS4K9rEklnaH9hWLzhZ41U\" -H \"Content-Type: application/json; charset=utf-8\" -d '{ \"article_text\": \"#{article_text}\"}' https://api.parse.com/1/classes/PitchforkBestNewMusic/#{id}`

			pp output

			abort

		end
  	end
end

threads.each {|t| t.join}
