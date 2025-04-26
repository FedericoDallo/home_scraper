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
      "locations=51731&min-roofed=#{MIN_DIMENSION}&min-price=&max-price=#{MAX_PRICE + GARAGE_PRICE_INCREASE}&currency=UYU&o=2,2&1=1"
    ]
  end

  def get_cards(doc)
    doc.css("#propiedades").css("li")
  end

  def get_title(card)
    card.at_css(".prop-desc-tipo-ub")&.text&.strip || ""
  end

  def get_href(card)
    card.children[1]["href"]
  end

  def get_price(card)
    get_price_number(card.children[3].children[0].text)
  end

  def get_description(doc)
    desc_html = doc.at_css("#prop-desc").text
    Nokogiri::HTML(desc_html).css("p").text.strip
  end

  def garages_on_info(doc)
    0
  end
end
