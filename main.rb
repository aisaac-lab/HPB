require 'bundler/setup'
require 'maxwell'
require 'pry'
require 'csv'

# $file_name = "上野・神田・北千住・亀有・青砥・町屋.csv"
# $url       = "http://beauty.hotpepper.jp/svcSA/macAZ/salon/PN%d.html?searchGender=ALL"
# $last_index = 16

# $file_name = "御茶ノ水・四ツ谷・千駄木・茗荷谷.csv"
# $url       = "http://beauty.hotpepper.jp/svcSA/macJA/salon/PN%d.html?searchGender=ALL"
# $last_index = 8

# $file_name = "両国・錦糸町・小岩・森下・瑞江.csv"
# $url       = "http://beauty.hotpepper.jp/svcSA/macJC/salon/PN%d.html?searchGender=ALL"
# $last_index = 15

$file_name = "センター南・二俣川・戸塚・杉田・金沢文庫.csv"
$url       = "http://beauty.hotpepper.jp/svcSA/macJM/salon/PN%d.html?searchGender=ALL"
$last_index = 19




$file_name = "門前仲町・勝どき・月島・豊洲.csv"
$url       = "http://beauty.hotpepper.jp/svcSA/macJQ/salon/PN%d.html?searchGender=ALL"
$last_index = 7

module Hotpepper
  class Beauty < Maxwell::Base
    attr_accessor :title, :url, :address

    concurrency 5

    def self.call
      self.execute self.urls
    end

    def self.urls
      (1..17).map { |i|
        $url % i
      }.map { |url| Maxwell::Helper.open_links(url, "h3.slcHead.cFix a") }.flatten

    end

    def parser html
      @title = html.title.gsub("｜ホットペッパービューティー", "")

      html.css("table.slnDataTbl.bdCell.bgThNml.fgThNml.vaThT.pCellV10H12 tr").map do |tr|
        if tr.css("th").text == "お店のホームページ"
          @url = tr.css("td a").text
        end
        if tr.css("th").text == "住所"
          @address = tr.css("td").text
        end
      end
    end

    def handler result
      CSV.open($file_name, "a") do |csv|
        csv << result.values
      end
    end
  end
end

Hotpepper::Beauty.call
