#!/usr/bin/env ruby
# -*- coding:utf-8 -*-

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'

def save_img(url, dst)
  filename = File.basename(url)
  open(dst + '/' +filename, 'wb') do |file|
    open(url) do |data|
      file.write(data.read)
    end
  end
end

def get_page_img(url, html, dst)
  uri = URI(url)
  uripath = uri.path.split("/")
  setsid  = uripath[4]

  threadlist = []

  html.xpath("//div[@class='photo-display-item']").each do |p|
    threadlist << Thread.new do
      imgid = p["data-photo-id"]
      #puts imgid
      #puts uri.scheme+"://"+uri.host+"/"+uripath[1,2].join("/")+"/"+imgid \
      #     + "/sizes/o/in/set-"+setsid
      org_url = uri.scheme+"://"+uri.host+"/"+uripath[1,2].join("/")+"/"+imgid \
                + "/sizes/o/in/set-"+setsid
      org_html = Nokogiri::HTML(open(org_url))
      imgurl = org_html.xpath("//div[@id='allsizes-photo']").xpath("./img")[0]["src"]
      # puts imgurl
      save_img(imgurl, dst)
    end
    #  imgpath = p.xpath("./a")[0]["href"]
    #  puts imgpath
    #  imgpath_list = imgpath.split("/")
    #  imgpath_list = imgpath_list[0,4] + ["sizes", "o"] + imgpath_list[4,5]
    #  p imgpath_list.join("/")
  end

  threadlist.each do |thread|
    thread.join
  end
end




if ARGV.length != 2 then
  puts "ruby getsets.rb [target] [dst dir]"
  exit(1)
end

url = ARGV[0]
dst = ARGV[1]

begin
  html = Nokogiri::HTML(open(url))
  puts url

  get_page_img(url, html, dst)

  next_page = html.xpath("//a[@data-track='next']")
  uri = URI(url)
  if next_page.length != 0 then
    url = uri.scheme+"://"+uri.host+html.xpath("//a[@data-track='next']")[0]["href"]
  end
end while next_page.length != 0
