# frozen_string_literal: true

module ScraperCommon
  MAX_PRICE = 38_000
  GARAGE_PRICE_INCREASE = 4_500

  MIN_DIMENSION = 45

  GARAGE_KEYWORDS = %w[garage cochera estacionamiento garaje gge gje]

  private

  def get_info(doc)
    [
      get_title(doc),
      URI::DEFAULT_PARSER.escape(get_href(doc)),
      get_price(doc)
    ]
  end

  def allowed_price?(price, card, url)
    price <= MAX_PRICE || (price <= MAX_PRICE + GARAGE_PRICE_INCREASE && has_garage?(card, url))
  end

  def has_garage?(card, url)
    garage_on_title?(card) || garage_on_page?(url)
  end

  def garage_on_title?(card)
    title = get_title(card)
    return false unless title.present?

    garage_in_text?(title)
  end

  def garage_on_page?(url)
    response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
    doc = Nokogiri::HTML(response.body)

    garages_on_info(doc) > 0 || garage_on_description?(doc)
  end

  def garage_on_description?(doc)
    description = get_description(doc)
    return false unless description.present?

    garage_in_text?(description)
  end

  def garage_in_text?(text)
    GARAGE_KEYWORDS.any? { |kw| text.downcase.include?(kw) }
  end

  def get_price_number(text)
    text.gsub(/\D/, '').to_i
  end

  def reserved?(card)
    false
  end

  def find_by_css_classes(doc, string)
    parsed_classes = string.split(" ").map { |klass| "." + klass }.join
    doc.css(parsed_classes)
  end

  def print_info(card)
    title, href, price = get_info(card)
    url = URI.join(base_url, href).to_s
    headers = { "User-Agent" => "Mozilla/5.0" }
    doc = Nokogiri::HTML(HTTParty.get(url, headers:))
    puts "Title: #{title}"
    puts "Url: #{url}"
    puts "Price: #{price}"
    puts "Description: #{get_description(doc)}"
    puts "Garage on title: #{garage_on_title?(card)}"
    puts "Garages on info: #{garages_on_info(doc)}"
    puts "Garage on description: #{garage_on_description?(doc)}"
    puts "Reserved: #{reserved?(card)}"
    safe_href = URI::DEFAULT_PARSER.escape(get_href(card))
    puts "Allowed price: #{allowed_price?(get_price(card), card, URI.join(base_url, safe_href).to_s)}"
    puts "*" * 100
  end
end
