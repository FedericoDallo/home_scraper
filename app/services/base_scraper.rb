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

  MAX_PRICE = 38_000
  GARAGE_PRICE_INCREASE = 4_500

  MIN_DIMENSION = 45

  def fetch_listings
    listings_path.map do |path|
      response = HTTParty.get("#{base_url}#{base_path}#{path}", headers: COMMON_HEADERS)
      doc = Nokogiri::HTML(response.body)

      get_cards(doc).map do |card|
        next if reserved?(card)

        title, href, price = get_info(card)
        url = URI.join(base_url, href).to_s
        next if !allowed_price?(price, card, url)

        { title:, url:, price: }
      end.compact.uniq { |l| l[:url] }
    end.flatten
  end

  private

  def allowed_price?(price, card, url)
    price <= MAX_PRICE || (price <= MAX_PRICE + GARAGE_PRICE_INCREASE && has_garage?(card, url))
  end

  def has_garage?(card, url)
    garage_on_title?(card) || garage_on_page?(url)
  end

  def reserved?(card)
    false
  end
end
