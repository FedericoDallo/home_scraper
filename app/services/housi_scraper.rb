require 'httparty'
require 'nokogiri'
require 'uri'

class HousiScraper < BaseScraper
  NAME = "housi"

  private

  def base_url
    "https://www.housi.com.uy"
  end

  def base_path
    "/Buscar?operation=2&ptypes=2&"
  end

  def listings_path
    [
      "locations=51731&min-roofed=45&min-price=&max-price=35000&currency=UYU&o=2,2&1=1"
    ]
  end

  def get_cards(doc)
    doc.css("#propiedades").css("li")
  end

  def get_info(card)
    [title(card), href(card), get_price(card)]
  end

  def title(card)
    card.at_css(".prop-desc-tipo-ub")&.text&.strip || ""
  end

  def href(card)
    card.children[1]["href"]
  end

  def get_price(card)
    get_price_number(card.children[3].children[0].text)
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
