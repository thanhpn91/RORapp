require 'nokogiri'
require 'open-uri'
require 'pg'

# db = Mongo::Connection.new.db("foodyDB")
# db = Mongo::Connection.new("localhost").db("foodyDB")
# db = Mongo::Connection.new("localhost",27017).db

class Crawler
  def self.web_parse(url,category)
  data = Nokogiri::HTML(open(url))
  concerts = data.css('.row-view .filter-result-item')
    title =''
    address =''
    description =''
    photos =''
    category= category
    temp = ""
      concerts.each do |concert|
        db = PG::Connection.open(:dbname => 'foody_development')
        if !concert.at_css('.result-name a').nil?
          if concert.at_css('.result-name a').text != ""
            # title
            title =  concert.at_css('.result-name a').text

            #address of place
            address = concert.at_css('.disableSelection div').css('span').text.gsub(/\s*\n\s*/, ", ")

            #description
            description = concert.at_css('.disableSelection .result-special .special-content1').css('span li').text

            #image
            photos = concert.at_css('.result-image a img')[:src]
            temp = db.exec('SELECT 1 FROM foodies WHERE title=$1 and address =$2 and category=$3',[title,address,category])
            if(temp.cmd_tuples == 0)
                 db.exec('INSERT INTO foodies (title,address,description,photos,category) VALUES
                 ($1,$2,$3,$4,$5)',[title,address,description,photos,category])
             end

          end
        end
        db.close
      end
  end
end