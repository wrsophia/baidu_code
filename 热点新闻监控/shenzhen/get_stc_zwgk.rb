#!/bin/usr/env ruby
# coding: gbk
#get_stc_zwgk.rb
#################################

require 'iconv'
require 'hpricot'
require 'net/http'
require 'rubygems'

html_in = File.open("#{ARGV[0]}","r")
doc = Hpricot(html_in)

f_out = File.open("#{ARGV[1]}","a+:gbk")

if (doc/"table#mytable tr").inner_html.to_s == ""
    res = Net::HTTP.get_response(URI.parse("#{ARGV[2]}"))
    doc = Hpricot(res.body)
end

  
(doc/"table#mytable tr").each do |news|
    if (news/"a").inner_html != ""
        href = (news/"a")[0].attributes['href']
        p_href = href[1..(href.length-1)]
        href = "http://www.stc.gov.cn/ZWGK/TZGG/GGJG" + p_href.strip
        title = "[shenzhen]" + Iconv.iconv("GBK//IGNORE", "UTF-8", (news/"a").inner_html.to_s)[0].strip
        time = Iconv.iconv("GBK//IGNORE", "UTF-8", (news/"td[3]").inner_html.to_s)[0].strip
        now = Time.now

        catch :doc_each do
            f_out.pos = 0
            while line = f_out.gets
                str = line.split
                if str[0] == href
                    throw :doc_each
                end
            end
            f_out.puts("#{href}\t#{title}\t#{time}\t#{now}\n")
        end
    end   
end

f_out.close
