class ImperiumInmobiliaria < BaseApi
  NAME = "imperium_inmobiliaria"

  def fetch_listing(url)
    response_http = HTTParty.get(url, headers: COMMON_HEADERS)
    response = JSON.parse(response_http.body).deep_symbolize_keys
    response[:response][:property] => { id:, title:, description: description_raw, price: prices }
    description_html = Nokogiri::HTML(description_raw)
    expenses = description_html.css("p").to_a.find { |coso| coso.text.downcase.include?("gastos comunes") }
    prices = [prices.to_i, get_price_number(expenses.text)]

    {
      id:,
      title:,
      url:,
      prices:
    }
  end

  private

  def front_url
    "https://www.inmobiliariaimperium.com"
  end 

  def base_url
    "https://imperium-prod.herokuapp.com/api"
  end

  def base_path
    "/listing-properties"
  end

  def base_path_details
    "/listing-property-details"
  end

  def generate_url(id)
    "#{base_url}#{base_path_details}?id=#{id}"
  end

  def get_query
    {
      currentPage: 0,
      bathrooms: "Todos",
      bedrooms: "Todos",
      state: "Montevideo",
      type: "Todos",
      operation: "Alquiler",
      region: "Pocitos",
      range: "$20.000 a $55.000",
      parking_lots: "Todos",
      has_patio: "Todos",
      has_balcony: "Todos",
      has_kitchen: "Todos",
    }
  end

  def get_info(result)
    [
      result[:title],
      get_url(result[:id]),
      [result[:price]]
    ]
  end

  def get_url(id)
    "#{front_url}/listing-property-details?id=#{id}"
  end
end
