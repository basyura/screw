
class Page < ActiveRecord::Base
  def self.crawl(url)
    info = Typhoo::Crawler.new.crawl(url)
    Page.new(info)
  end
end
