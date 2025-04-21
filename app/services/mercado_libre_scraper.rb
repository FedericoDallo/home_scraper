require 'httparty'
require 'nokogiri'
require 'uri'

class MercadoLibreScraper < BaseScraper
  NAME = "mercado_libre"

  private

  def base_url
    "https://listado.mercadolibre.com.uy"
  end

  def base_path
    "/inmuebles/alquiler"
  end

  def listings_path
    [
      "/mas-de-1-dormitorios/_PublishedToday_YES_PriceRange_0UYU-#{MAX_PRICE + GARAGE_PRICE_INCREASE}UYU_COVERED*AREA_45-*_FULL*BATHROOMS_1-*_PROPERTY*TYPE_242062,242060_item*location_lat:-34.918204*-34.906844,lon:-56.152747*-56.143262",
      "/mas-de-1-dormitorios/_PriceRange_0UYU-#{MAX_PRICE + GARAGE_PRICE_INCREASE}UYU_PublishedToday_YES_COVERED*AREA_50-*_PROPERTY*TYPE_242060,242062_TOTAL*AREA_55-*_item*location_lat:-34.926307*-34.908212,lon:-56.162405*-56.147295"
    ]
  end

  def get_cards(doc)
    doc.css("li.ui-search-layout__item")
  end

  def get_info(card)
    [title(card), href(card), get_price(card)]
  end

  def title(card)
    card.at_css("a.poly-component__title")&.text&.strip || ""
  end
  
  def href(card)
    card.at_css("a.poly-component__title")["href"].split("#")[0]
  end

  def get_price(card)
    card.at_css("div.poly-price__current span.andes-money-amount__fraction")&.text&.strip.gsub(".", "").to_i
  end

  def garage_on_title?(card)
    title = card.at_css("a.poly-component__title")&.text&.strip #cambiar por el nuevo selector
    return false unless title.present?

    garage_in_text?(title)
  end
  
  def garage_on_page?(url)
    response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
    doc = Nokogiri::HTML(response.body)

    garages_on_info(doc) > 0 || garage_on_description?(doc)
  end

  def garages_on_info(doc)
    0
  end

  def garage_on_description?(doc)
    description = doc.at_css(".ui-pdp-collapsable__container")&.children&.first&.children&.last&.text
    return false unless description.present?

    garage_in_text?(description)
  end
end