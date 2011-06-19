#!ruby
#-*- coding: utf-8 -*-

require 'net/http'
require 'json'
require 'mechanize'
require 'kconv'
require 'pstore'
require 'uri'
require 'yaml'

module Typhoo
  class Crawler
    include ActionView::Helpers::SanitizeHelper
    SITE_INFO_API  = "http://wedata.net/databases/LDRFullFeed/items.json"
    SITE_INFO_PATH = "#{Rails.root}/db/wedata.yaml"
    def initialize
      # TODO: initializer
      create_site_info(SITE_INFO_PATH) unless File.exist? SITE_INFO_PATH
      @sources = YAML.load_file(SITE_INFO_PATH)
    end
    def crawl(url)
      start = Time.now
      print "crawl #{url} ... "
      host  = URI.parse(url).host
      #xpath = @sources.has_key?(host) ? @sources[host] : '/'
      xpath = '/'
      @sources.each do |site|
        if url =~ /#{site[:url]}/
          xpath = site[:xpath]
          puts "site url   = #{site[:url]}"
          puts "site xpath = #{xpath}"
          break
        end
      end
      xpath = xpath.gsub(/(id\("(.*?)"\))/,'[@id="\\2"]')
      puts "xpath = #{xpath}"
      page = Mechanize.new.get(url)
      #page.encoding = encoding if encoding
      while true
        begin
          node = page.at(xpath)
          break
        rescue
          print " retry "
          xpath = xpath.slice(/(.*)\// , 1)
          if !xpath || !xpath.include?("/")
            print "give up"
            xpath = '/'
            node = page.at(xpath)
            break
          end
        end
      end
      content = node.to_s.toutf8.gsub("" , "")
      content = content.gsub(/<script.*?>.*?<\/script>/m,"")
      #content = content.gsub(/<iframe.*?>.*?<\/iframe>/m,"")
      content = strip_tags(content)
      content = content.gsub(/\n[\n\s]+/,"<br>")
      content = content.gsub("\n","<br>")
      content = "<a href='#{url}'>#{page.title}</a><br>" + content
      puts "done (#{Time.now - start})"
      h = ActiveSupport::HashWithIndifferentAccess.new
      h[:content] = content
      h[:title]   = page.title
      h[:url]     = url
      h[:xpath]   = xpath
      h
    end
    private
    def create_site_info(path)
      # TODO: "\xA9" from ASCII-8BIT to UTF-8
      list = []
      get_site_info.each do |site|
        url  = site["data"]["url"].gsub(/[\^\\]/ , "")
        host = (URI.parse(url).host rescue nil) ||  ""
        next unless host.empty?
        xpath = site["data"]["xpath"]
        list << {:url => url , :xpath => xpath , :host => host}
      end
      YAML.dump(list , File.open(path , 'w'))
    end
    def get_site_info
      url = URI.parse(SITE_INFO_API)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host , url.port) do |http|
        http.request(req)
      end
      JSON.parse res.body
    end
  end
end

if __FILE__ == $0
  #url = 'http://d.hatena.ne.jp/basyura'
  #url = 'http://blog.livedoor.jp/nwknews/archives/3803948.html'
  url = 'http://news.2chblog.jp/archives/51614888.html'
  p Typhoo::Crawler.new.crawl(url)
end

#url = 'http://blog.livedoor.jp/nwknews/archives/3803948.html'
#info = Typhoo::Crawler.new.crawl(url)
#puts info[:content]

=begin
{
  "name"=>"タイトル", 
  "resource_url"=>"http://wedata.net/items/54438", 
  "updated_at"=>"2011-06-13T20:21:16+09:00", 
  "created_by"=>"cabkip", 
  "database_resource_url"=>"http://wedata.net/databases/LDRFullFeed", 
  "data"=>{
    "url"=>"^http://hogehoge\\.net/", 
    "type"=>"IND", 
    "xpath"=>"//div[@class=\"entry-body clearfix\"]"}, 
    "created_at"=>"2011-06-13T20:07:32+09:00"
  }
=end




#target = 'http://d.hatena.ne.jp/basyura'
#target = 'http://headlines.yahoo.co.jp/hl?a=20110616-00000131-jij-soci'
#target = 'http://vinarian.blogspot.com/2010/10/saint-vimmer.html'
#target = 'http://qwik.jp/guruby/21.html'
#target = 'http://alfalfalfa.com/archives/3576605.html'
#target = 'http://blog.livedoor.jp/dankogai/archives/51695967.html'
#target = 'http://news.livedoor.com/article/detail/5637705/'

#crawl('http://saxbluemurmur.jugem.cc/?cid=5' , '//div[(@class="entry_body") or (@class="entry_more")]' , 'saxbluemurmur' , 'euc-jp')
#crawl('http://acru.jp/blog/staff_blog/1355' , 'div[contains(concat(" ", @class, " "), " details ")]d' , 'aru')
#crawl('http://www.theatlantic.com/infocus/2011/06/diy-weapons-of-the-libyan-rebels/100086/' , '//div[@class="articleContent"]|//div[@class="articleContent"]/following-sibling::span' , 'infocus')
#crawl('http://d.hatena.ne.jp/basyura/20110502' , 'id("days")//div[@class="body"]//h3/following-sibling::*' , 'basyura.hatena')
#crawl('http://d.hatena.ne.jp/basyura/20110502' , 'id("days")//div[@class="body"]' , 'basyura.hatena')
#crawl('http://blog.livedoor.jp/booq/archives/1444153.html' , 'id("blogbody_id")' , 'livedoor')
#crawl('http://www.sonypictures.jp/blogs/sonypicturesplus/2011/06/post_371.php' , '//div[@class="content"]' , 'sonypictures')
#crawl('http://d.hatena.ne.jp/basyura/' , 'id("days")//div[@class="body"]' , 'basyura.hatena')
#crawl('http://blog.livedoor.jp/booq/'  , 'id("blogbody_id")' , 'livedoor')
#crawl('http://www.sonypictures.jp/blogs/sonypicturesplus/' , '//div[@class="content"]' , 'sonypictures')
#crawl('http://blog.livedoor.jp/dankogai/archives/51694301.html' , '//div[@class="main"]' , 'dankogai')
#crawl('http://blog.livedoor.jp/dankogai/' , '//div[@class="main"]' , 'dankogai')
#crawl('http://www.47news.jp/localnews/hotnews/2011/06/post-20110615161911.html' , 'id("bt_body")' , 'localnews')
#crawl('http://www.47news.jp/localnews/' , 'id("bt_body")' , 'localnews')
#
#

