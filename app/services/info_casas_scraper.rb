require 'httparty'
require 'nokogiri'
require 'uri'

class InfoCasasScraper
  BASE_URL = "https://www.infocasas.com.uy"
  BASE_PATH = "/alquiler/casas-y-apartamentos/montevideo"
  LISTINGS_PATH  = "/pocitos-y-en-pocitos-nuevo-y-en-punta-carretas/1-o-mas-dormitorios/hasta-38000/pesos/m2-desde-45/totales/incluyendo-gastos-comunes/publicado-hoy"

  NAME = "info_casas"

  def fetch_listings
    response = HTTParty.get("#{BASE_URL}#{BASE_PATH}#{LISTINGS_PATH}")
    doc = Nokogiri::HTML(response.body)

    doc.css("section.listingsWrapper a.lc-cardCover").map do |a|
      {
        title: a["title"],
        url: URI.join(BASE_URL, a["href"]).to_s
      }
    end.compact
  end
end
