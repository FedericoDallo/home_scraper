require 'httparty'

class BaseApi
  include ScraperCommon

  def fetch_listings(mode = 0)
    puts "Fetching #{base_url}" if mode == DEBUGGING_MODE
    response_http = HTTParty.get("#{base_url}#{base_path}", headers: COMMON_HEADERS, query: get_query)

    response = JSON.parse(response_http.body).deep_symbolize_keys
    response[:response][:result].pluck(:property).filter_map do |result|
      next if useless?(result)

      title, href, prices = get_info(result)
      url = URI.join(base_url, href).to_s
      next if !allowed_price?(prices, result, url)

      {
        title:,
        url:,
        prices:
      }
    end
  end

  private

  def allowed_price?(prices, card, url)
    return prices.sum <= MAX_PRICE || (prices.sum <= MAX_PRICE + GARAGE_PRICE_INCREASE && garage_on_title?(card)) if prices.size == 2

    fetch_listing(url) => { expenses:, garages: }
    prices << expenses
    prices.sum <= MAX_PRICE + GARAGE_PRICE_INCREASE * garages
  end

  def useless?(result)
    false
  end
end
