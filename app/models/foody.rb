require_relative 'crawler'
class Foody < ActiveRecord::Base
  def self.call_parse
    Crawler.web_parse("http://www.foody.vn/ho-chi-minh/cafe",1)
    Crawler.web_parse("http://www.foody.vn/ho-chi-minh/nha-hang",2)
    Crawler.web_parse("http://www.foody.vn/ho-chi-minh/bar-pub",3)
  end
end
