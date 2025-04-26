class RemaxScraper < BaseScraper
  NAME = "remax"

  private

  def base_url
    "https://www.remax.com.uy"
  end

  def base_path
    "/listings/rent"
  end

  def listings_path
    [
      "?page=0&pageSize=50&sort=-createdAt&in:operationId=2&in:eStageId=0,1,2,3,4&in:typeId=1,2,3,4,5,6,7,8&pricein=3:0:#{MAX_PRICE + GARAGE_PRICE_INCREASE}&gte:dimensionCovered=#{MIN_DIMENSION}&locations=in:::1441@%3Cb%3EPocitos%3C%2Fb%3E::::"
    ]
  end

  def get_cards(doc)
    doc.css(".card-remax", ".viewList")
  end

  def reserved?(card)
    card.at_css("qr-tag p")&.text&.strip&.downcase == "reservada"
  end

  def get_title(card)
    card.at_css("p.card__description")&.text&.strip ||
      card.at_css("a.card-remax__href")&.text&.strip
  end

  def get_href(card)
    card.at_css("a.card-remax__href")["href"]
  end

  def get_price(card)
    children = card.at_css(".card__price-and-expenses").children
    base_price = get_price_number(children[1].children.first.text)
    expenses = get_price_number(children[2].children.first.text)

    base_price + expenses
  end

  def get_description(doc)
    doc.at_css("#last")&.text&.strip
  end

  def garages_on_info(doc)
    doc.at_css('[data-info="parkingSpaces"]')&.children.to_a[1]&.text.to_i
  end
end
