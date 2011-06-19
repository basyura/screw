class Stock < ActiveRecord::Base
  before_save :set_title
  protected
  def after_initialize
    self.read ||= 0
  end
  def set_title
    page = Page.where(:url => self.url).first
    if page
      self.title = page.title
    else
      page = Page.crawl(self.url)
      page.save
      self.title = page.title
    end
  end
end
