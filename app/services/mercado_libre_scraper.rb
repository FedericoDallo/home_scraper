require 'httparty'
require 'nokogiri'
require 'uri'

class MercadoLibreScraper
  BASE_URL = "https://listado.mercadolibre.com.uy"
  BASE_PATH = "/inmuebles/alquiler"
  LISTINGS_PATH  = [
    "/mas-de-1-dormitorios/_PublishedToday_YES_PriceRange_0UYU-35000UYU_COVERED*AREA_45-*_FULL*BATHROOMS_1-*_PROPERTY*TYPE_242062,242060_item*location_lat:-34.918204*-34.906844,lon:-56.152747*-56.143262",
    "/mas-de-1-dormitorios/_PriceRange_0UYU-35000UYU_PublishedToday_YES_COVERED*AREA_50-*_PROPERTY*TYPE_242060,242062_TOTAL*AREA_55-*_item*location_lat:-34.926307*-34.908212,lon:-56.162405*-56.147295"
  ]

  NAME = "mercado_libre"

  def fetch_listings
    LISTINGS_PATH.map do |path|
      encoded_url = URI.join(BASE_URL, URI::DEFAULT_PARSER.escape(BASE_PATH + path)).to_s
      response = HTTParty.get(encoded_url, headers: { "User-Agent" => "Mozilla/5.0" })
  
      doc = Nokogiri::HTML(response.body)
  
      doc.css("li.ui-search-layout__item").map do |li|
        anchor = li.at_css("a.poly-component__title")
        price = li.at_css("div.poly-price__current span.andes-money-amount__fraction")
  
        next unless anchor
  
        {
          title: anchor.text.strip,
          url: anchor["href"].split("#")[0]
        }
      end.compact.uniq { |l| l[:url] }
    end.flatten
  end
end