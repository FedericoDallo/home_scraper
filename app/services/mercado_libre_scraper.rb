require 'httparty'
require 'nokogiri'
require 'uri'

class MercadoLibreScraper
  BASE_URL = "https://listado.mercadolibre.com.uy"
  BASE_PATH = "/inmuebles/alquiler"
  LISTINGS_PATH  = "/mas-de-1-dormitorios/_PublishedToday_YES_PriceRange_0UYU-35000UYU_COVERED*AREA_45-*_FULL*BATHROOMS_1-*_PROPERTY*TYPE_242062,242060_item*location_lat:-34.918204*-34.906844,lon:-56.152747*-56.143262"

  NAME = "mercado_libre"

  def fetch_listings
    encoded_url = URI.join(BASE_URL, URI::DEFAULT_PARSER.escape(LISTINGS_PATH)).to_s
    response = HTTParty.get(encoded_url, headers: { "User-Agent" => "Mozilla/5.0" })

    doc = Nokogiri::HTML(response.body)

    doc.css("li.ui-search-layout__item").map do |li|
      anchor = li.at_css("a.poly-component__title")
      price = li.at_css("div.poly-price__current span.andes-money-amount__fraction")

      next unless anchor

      {
        title: anchor.text.strip,
        url: anchor["href"]
      }
    end.compact.uniq { |l| l[:url] }
  end
end