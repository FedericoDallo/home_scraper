require 'httparty'
require 'nokogiri'
require 'uri'

class BaseScraper
  include ScraperCommon

  def fetch_listings(mode = 0)
    listings_path.map do |path|
      safe_path = URI::DEFAULT_PARSER.escape("#{base_path}#{path}")
      puts "Fetching #{base_url}#{safe_path}" if mode == DEBUGGING_MODE
      response = HTTParty.get("#{base_url}#{safe_path}", headers: COMMON_HEADERS)
      doc = Nokogiri::HTML(response.body)

      results = get_cards(doc).filter_map do |card|
        print_info(card) if mode == DEBUGGING_MODE
        next if reserved?(card)

        title, href, prices = get_info(card)
        url = URI.join(base_url, href).to_s
        next if !allowed_price?(prices, card, url)

        if mode == NORMAL_MODE
          { title:, url:, prices: prices.sum }
        else
          instance_doc = Nokogiri::HTML(HTTParty.get(url, headers: COMMON_HEADERS).body)
          {
            title:,
            url:,
            prices: { base: prices[0], expenses: prices[1] },
            description: get_description(instance_doc),
            garage_on_title: garage_on_title?(card),
            garages_on_info: garages_on_info(instance_doc),
            garage_on_description: garage_on_description?(instance_doc),
            reserved: reserved?(card),
            allowed_price: allowed_price?(prices, card, url)
          }
        end
      end

      if mode == DEBUGGING_MODE
        puts
        puts "=" * 100
        puts "=" * 100
        puts
      end

      results
    end.flatten.uniq { |l| l[:url] }
  end

  private

  def allowed_price?(prices, card, url)
    return prices.sum <= MAX_PRICE || (prices.sum <= MAX_PRICE + GARAGE_PRICE_INCREASE && garage_on_title?(card)) if prices.size == 2

    response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
    doc = Nokogiri::HTML(response.body)

    prices << get_expenses(doc)
    prices.sum <= MAX_PRICE || (prices.sum <= MAX_PRICE + GARAGE_PRICE_INCREASE && garage_on_page?(doc))
  end
end
