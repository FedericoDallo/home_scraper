class ImperiumInmobiliaria < BaseApi
  NAME = "imperium_inmobiliaria"

  def fetch_listing(url)
    response_http = HTTParty.get(url, headers: COMMON_HEADERS)
    response = JSON.parse(response_http.body).deep_symbolize_keys
    response[:response][:property] => { id:, title:, description: description_raw, price:, parking: garages }
    description_html = Nokogiri::HTML(description_raw)
    expenses_html = description_html.css("p").to_a.find { |coso| coso.text.downcase.include?("gastos comunes") }
    expenses = get_price_number(expenses_html&.text.to_s)

    {
      id:,
      title:,
      url: get_front_url(id),
      price:,
      expenses: expenses.to_i,
      garages: garages.to_i,
      description: description_html.text
    }
  end

  private

  def useless?(result)
    result[:area].to_i < effective_bounds.min_dimension || result[:bedrooms].to_i.zero?
  end

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
      [result[:price].to_i]
    ]
  end

  def get_url(id)
    "#{base_url}#{base_path_details}?id=#{id}"
  end

  def get_front_url(id)
    "#{front_url}#{base_path_details}?id=#{id}"
  end
end
