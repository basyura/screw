
class Page < ActiveRecord::Base
  def self.crawl(url)
    info = Screw::Crawler.new.crawl(url)
    Page.new(info)
  end
end
