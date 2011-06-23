#!ruby
#-*- coding: utf-8 -*-

require 'net/http'
require 'json'
require 'mechanize'
require 'kconv'
require 'pstore'
require 'uri'
require 'yaml'
require 'extractcontent'

=begin

wedata api

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

module Screw
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
      agent = Mechanize.new
      if ENV['http_proxy']
        proxy = URI.parse(ENV['http_proxy'])
        agent.set_proxy(proxy.host , proxy.port)
      end
      page  = agent.get(url)

      source = @sources.detect{|site| url =~ /#{site[:url]}/ }
      if source
        content = extract_content_with_xpath(page, source[:xpath])
      else
        source = {:xpath => 'extract'}
        content, title = ExtractContent::analyse(page.at('body').to_s.toutf8) # 本文抽出
      end
      content = content.gsub("" , "")
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
      h[:xpath]   = source[:xpath]
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
    def extract_content_with_xpath(page , xpath)
      xpath = xpath.gsub(/(id\("(.*?)"\))/,'[@id="\\2"]')
      puts "xpath = #{xpath}"
      #page.encoding = encoding if encoding
      while true
        begin
          return page.at(xpath).to_s.toutf8
        rescue
          print " retry "
          xpath = xpath.slice(/(.*)\// , 1)
          if !xpath || !xpath.include?("/")
            print "give up"
            xpath = 'body'
            return page.at(xpath).to_s.toutf8
          end
        end
      end
    end
  end
end

if __FILE__ == $0
  url = 'http://news.2chblog.jp/archives/51614888.html'
  p Screw::Crawler.new.crawl(url)
end

