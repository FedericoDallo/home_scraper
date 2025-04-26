require 'httparty'
require 'nokogiri'
require 'uri'

class BaseScraper
  include ScraperCommon

  COMMON_HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language" => "en-US,en;q=0.5"
  }

  def fetch_listings(debugging_mode = false)
    listings_path.map do |path|
      safe_path = URI::DEFAULT_PARSER.escape("#{base_path}#{path}")
      puts "Fetching #{base_url}#{safe_path}" if debugging_mode
      response = HTTParty.get("#{base_url}#{safe_path}", headers: COMMON_HEADERS)
      doc = Nokogiri::HTML(response.body)

      results = get_cards(doc).map do |card|
        print_info(card) if debugging_mode
        next if reserved?(card)

        title, href, price = get_info(card)
        url = URI.join(base_url, href).to_s
        next if !allowed_price?(price, card, url)

        { title:, url:, price: }
      end.compact.uniq { |l| l[:url] }

      if debugging_mode
        puts
        puts "=" * 100
        puts "=" * 100
        puts
      end

      results
    end.flatten
  end
end
