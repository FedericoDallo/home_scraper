require 'httparty'

class BaseApi
  include ScraperCommon

  def fetch_listings(mode = 0)
    puts "Fetching #{base_url}" if mode == DEBUGGING_MODE
    response_http = HTTParty.get("#{base_url}#{base_path}", headers: COMMON_HEADERS, query: get_query)

    response = JSON.parse(response_http.body).deep_symbolize_keys
    response[:response][:result].pluck(:property).map do |result|
      title, url, prices = get_info(result)
      {
        title:,
        url:,
        prices:
      }
    end
  end
end
