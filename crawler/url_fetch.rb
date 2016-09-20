require 'net/http'
require 'json'
require 'open-uri'
require 'digest/md5'
require "csv"

# Bing API key.
APIKEY = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

# ARGV[0]: ラベル
# ARGV[1]: 検索ワード

LABEL=ARGV[0]
SEARCH_WORD=ARGV[1]

#
# keywordでbing画像検索し画像のURLを取得しcsvを出力します
# csv:
#  <keyword>,<url>,<url-md5_hash>
#

SCRIPT_DIR = File.expand_path(File.dirname(__FILE__))

def get(label, keyword, skip = 0)
  url = "https://api.datamarket.azure.com/Bing/Search/v1/Composite?Sources=%27image%27&Query=#{query(keyword)}&Market=%27ja-JP%27&Adult=%27Strict%27&ImageFilters=%27Size%3ALarge%27&$format=json&$skip=#{skip}"

  uri = URI(url)
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth('', APIKEY)
  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(req)
  end
  body = JSON.parse(res.body, :symbolize_names => true)

  CSV.open("#{SCRIPT_DIR}/#{label}.csv", "wb") do |csv|
      body[:d][:results][0][:Image].each do |page|
        media_url = page[:MediaUrl]
        md5 = Digest::MD5.hexdigest(media_url)
        puts "#{keyword},#{media_url},#{md5}"
        csv << ["#{keyword}","#{media_url}","#{md5}"]
    end
  end

  sleep 5
end

def query(search_term)
  return URI.encode_www_form_component('\'' + search_term + '\'')
end

[100,200,300].each do |skip|
  get(LABEL, SEARCH_WORD, skip)

  # begin
  #   File.open('config.txt') do |file|
  #     file.each_line do |labmen|
  #       s = labmen.split("\t")
  #       print s[0]+':'+s[1]
  #       get(s[0], s[1], skip)
  #     end
  #   end
  # rescue SystemCallError => e
  #   puts %Q(class=[#{e.class}] message=[#{e.message}])
  # rescue IOError => e
  #   puts %Q(class=[#{e.class}] message=[#{e.message}])
  # end

  #get('ももクロ', skip)
  #get('ももいろクローバーZ', skip)
  #get('momota', '百田夏菜子', skip)
  #get('tamai', '玉井詩織', skip)
  #get('sasaki', '佐々木彩夏', skip)
  #get('ariyasu', '有安杏果', skip)
  #get('takagi', '高城れに', skip)
  #et('kawakami', '川上アキラ', skip)
  #get('furuya', '古屋智美', skip)
end
