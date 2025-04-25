class SorhuetScraper < BaseScraper
  NAME = "sorhuet"

  private

  def base_url
    "https://www.sorsap.com.uy"
  end

  def base_path
    "/propiedades/Alquiler"
  end

  def listings_path
    [
      "/$U/Sin_precio_mínimo/#{MAX_PRICE + GARAGE_PRICE_INCREASE}/Apartamento/Montevideo-Pocitos/Habitaciones-1-2"
    ]
  end

  def get_cards(doc)
    doc.at_css(".contenido").css(".propiedad")
  end

  def get_title(card)
    card.at_css(".ubicacion", ".atright")&.text&.strip || ""
  end

  def get_href(card)
    card.at_css("a")["href"]
  end

  def get_price(card)
    get_price_number(card.at_css(".precio").text)
  end

  def get_description(doc)
    doc.at_css(".col_left").children[11].text&.strip
  end

  def garages_on_info(doc)
    0
  end
end
