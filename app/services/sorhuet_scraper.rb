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

  def get_prices(card)
    [get_price_number(card.at_css(".precio").text)]
  end

  def get_metadata(card)
    card.css(".dato")
  end

  def get_expenses(doc)
    metadata = get_metadata(doc)
    return 0 unless metadata.present?

    expenses = metadata.find { |item| item.text.include?("Gastos comunes:") }
    return 0 unless expenses.present?

    get_price_number(expenses.children[1].text.strip)
  end

  def get_description(doc)
    doc.at_css(".col_left").children[11].text&.strip
  end

  def garages_on_info(doc)
    metadata = get_metadata(doc)
    return 0 unless metadata.present?

    garages = metadata.find { |item| item.text.include?("Garages:") }
    return 0 unless garages.present?

    garages.children[1].text.strip.to_i
  end
end
