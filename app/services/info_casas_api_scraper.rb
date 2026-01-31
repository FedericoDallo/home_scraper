require_relative 'utils/map'

class InfoCasasApiScraper < BaseApi
  NAME = "info_casas"

  def fetch_listings(mode = 0)
    response = HTTParty.post(base_url, headers:, body:)
    response.parsed_response[0].deep_symbolize_keys[:data][:searchFast][:data].map do |result|
      hash = result.slice(:id, :title, :description, :price, :commonExpenses)
      hash[:url] = URI.join(base_front_url, result[:link]).to_s
      hash[:expenses] = hash.delete(:commonExpenses)
      hash[:garages] = result[:facilities].include?("9") ? 1 : 0
      hash
    end
  end

  private
  
  def headers
    {
      accept: "*/*",
      "accept-language": "es-419,es;q=0.9",
      authorization: "",
      "content-type": "application/json",
      "ic-user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36",
      priority: "u=1, i",
      "sec-ch-ua": "  \"Chromium\";v=\"136\", \"Google Chrome\";v=\"136\", \"Not.A/Brand\";v=\"99\"",
      "sec-ch-ua-mobile": "?0",
      "sec-ch-ua-platform": "\"Windows\"",
      "sec-fetch-dest": "empty",
      "sec-fetch-mode": "cors",
      "sec-fetch-site": "same-site",
      "x-cookiepot": "3",
      "x-origin": "www.infocasas.com.uy"
    }
  end

  def body
    b = effective_bounds
    max_price_param = b.max_price + b.garage_price_increase
    m2_min = b.min_dimension
    params = {
      page:1,
      order:2,
      bedroomsExactMode:false,
      bathroomsExactMode:false,
      operation_type_id:2,
      property_type_id:[2],
      season:nil,
      dateFrom:nil,
      dateTo:nil,
      currencyID:2,
      m2Currency:2,
      guests:nil,
      projects:nil,
      minPrice:nil,
      maxPrice: max_price_param,
      commonExpenses:nil,
      rooms:nil,
      mapView:false,
      neighborhood_id:[],
      estate_id:nil,
      bedrooms:[1],
      publicationDate:0,
      m2Min: m2_min,
      m2Max:nil,
      map_polygon:MAP_POLYGON2,
      map_bounds:MAP_BOUNDS2
    }
    JSON.generate([{
      operationName:"ResultsGird_v2",
      variables: { rows:50, params: params, page:1, source:0 },
      query:
      "query ResultsGird_v2($rows: Int!, $params: SearchParamsInput!, $page: Int, $source: Int) {\n  searchFast(params: $params, first: $rows, page: $page, source: $source)\n}\n"},
    {
      operationName:"searchUrl",
      variables: { params: params },
      query:
      "query searchUrl($params: SearchParamsInput!) {
        searchUrl(params: $params) {
          url
          __typename
        }
      }"
    }])
  end

  def base_url
    "https://graph.infocasas.com.uy/graphql"
  end

  def base_front_url
    "https://www.infocasas.com.uy"
  end
end
