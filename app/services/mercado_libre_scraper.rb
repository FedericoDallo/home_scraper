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

  def get_title(card)
    card.at_css("a.poly-component__title")&.text&.strip || ""
  end
  
  def get_href(card)
    card.at_css("a.poly-component__title")["href"].split("#")[0]
  end

  def get_prices(card)
    [card.at_css("div.poly-price__current span.andes-money-amount__fraction")&.text&.strip.gsub(".", "").to_i]
  end

  def get_metadata(doc)
    doc.at_css(".ui-pdp-specs")
  end

  def get_expenses(doc)
    expenses_text = doc.at_css(".ui-pdp-color--GRAY.ui-pdp-size--XSMALL.ui-pdp-family--REGULAR.ui-pdp-maintenance-fee-ltr")&.text
    return 0 unless expenses_text.present?

    get_price_number(expenses_text) || 0
  end

  def get_description(doc)
    doc.at_css(".ui-pdp-collapsable__container")&.children&.first&.children&.last&.text
  end

  def garages_on_info(doc)
    garage_info = get_metadata(doc)&.css(".andes-table__body")&.children&.find { |child| child.text.include?("Cocheras") }
    return 0 unless garage_info.present?

    garage_info&.children[1]&.text&.to_i
  end
end
