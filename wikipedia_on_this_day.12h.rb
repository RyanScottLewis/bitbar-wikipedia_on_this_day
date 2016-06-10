#!/usr/bin/env ruby
# <bitbar.title>Wikipedia On This Day</bitbar.title>
# <bitbar.version>0.1.0</bitbar.version>
# <bitbar.author>Ryan Scott Lewis</bitbar.author>
# <bitbar.author.github>RyanScottLewis</bitbar.author.github>
# <bitbar.desc>Display Wikipedia On This Day information.</bitbar.desc>
# <bitbar.image>https://raw.githubusercontent.com/RyanScottLewis/bitbar-wikipedia_on_this_day/master/Screenshot.png</bitbar.image>
# <bitbar.dependencies>ruby (wikipedia, wikicloth, nokogiri rubygems)</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/RyanScottLewis/bitbar-wikipedia_on_this_day</bitbar.abouturl>

require "wikipedia" # gem install wikipedia-client
require "wikicloth" # gem install wikicloth
require "nokogiri"  # gem install nokogiri

within_events_section = false
day_str = Time.now.strftime("%B %e")

wiki_api_response = Wikipedia.find(day_str)

lines = wiki_api_response.content.lines.each_with_object([]) do |line, memo|
  wiki_document = WikiCloth::Parser.new(data: line)
  html_document = Nokogiri::HTML(wiki_document.to_html)

  headline_node = html_document.xpath("//h2/span[@class='mw-headline']").first

  if !headline_node.nil?
    within_events_section = headline_node.text == "Events"
  else
    next unless within_events_section
    list_item_node = html_document.xpath("//ul/li")

    memo << list_item_node.text

    wiki_document.internal_links.each do |page_title|
      url = "https://en.wikipedia.org/wiki/#{page_title.gsub(" ", "_")}"

      memo << "-- #{page_title} | href=#{url}"
    end
  end
end

puts "ⓦ"
puts "---"
lines.each { |line| puts(line) }
