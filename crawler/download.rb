require 'csv'
require 'net/http'
require 'digest/md5'
require 'openssl'
require 'time'

# ARGV[0]: CSVファイル
# ARGV[1]: 出力ディレクトリ

SCRIPT_DIR = File.expand_path(File.dirname(__FILE__))

DIST_DIR=ARGV[1]
OUT_CSV_PATH="#{SCRIPT_DIR}/download_imgs.#{Time.now.to_i}.csv"

unless File.exist?(DIST_DIR)
  puts "mkdir -p #{DIST_DIR}"
  Dir.mkdir(DIST_DIR)
end

def fetch(keyword, url)
  puts uri = URI(url)
  filename = uri.path.split('/').last
  ext = filename.split('.').last

  req = Net::HTTP::Get.new(uri.request_uri)
  nhttp = Net::HTTP.new(uri.host, uri.port)
  nhttp.use_ssl = uri.scheme == 'https'
  nhttp.verify_mode=OpenSSL::SSL::VERIFY_NONE

  res = nhttp.start() do |http|
    http.request(req)
  end

  md5 = Digest::MD5.hexdigest(res.body)
  puts dist_path = "#{DIST_DIR}/#{md5}.#{ext}"
  File.open(dist_path, 'w') do |file|
    file.write(res.body)
  end

  dist_path
end

out_csv = []

CSV.foreach(ARGV[0]) do |row|
  keyword = row[0]
  url = row[1]

  begin
    dist_path = fetch(keyword, url)
    out_csv << [keyword, url, dist_path]
  rescue => e
    puts e.message
  end
end

puts "write csv"

File.open(OUT_CSV_PATH, 'a') do |file|
  out_csv.each do |row|
    file.write(row.join(','))
  end
end
