class InfoCasasScraper < BaseScraper
  NAME = "info_casas"

  private

  def base_url
    "https://www.infocasas.com.uy"
  end

  def base_path
    "/alquiler/casas-y-apartamentos/montevideo"
  end

  def listings_path
    [
      "/pocitos-y-en-pocitos-nuevo-y-en-punta-carretas/1-o-mas-dormitorios/hasta-#{MAX_PRICE + GARAGE_PRICE_INCREASE}/pesos/m2-desde-#{MIN_DIMENSION}/totales/incluyendo-gastos-comunes/publicado-hoy"
    ]
  end

  def get_cards(doc)
    doc.css(".lc-data")
  end

  def get_title(card)
    card["title"].capitalize || ""
  end

  def get_href(card)
    card["href"]
  end

  def get_price(card)
    card.at_css(".lc-price").children.map(&:children).then do |base_price_container, expenses_container = []|
      [
        get_price_number(base_price_container.last.text),
        (get_price_number(expenses_container[2]&.text) rescue 0)
      ].sum
    end
  end

  def get_next_data(doc)
    cdata_node = doc.at('script#__NEXT_DATA__').children.first
    json_text = cdata_node.text

    JSON.parse(json_text)
  end

  def garages_on_info(doc)
    json_data = get_next_data(doc)

    props = json_data.dig("props", "pageProps", "apolloState")
    property = props&.values&.find { |v| v.is_a?(Hash) && v["__typename"] == "Property" }

    property["garage"]
  end

  def get_description(doc)
    classes = "ant-typography property-description"
    find_by_css_classes(doc, classes)&.text&.strip
  end
end
