# frozen_string_literal: true

module ScraperCommon
  MAX_PRICE = 38_000
  GARAGE_PRICE_INCREASE = 4_500

  MIN_DIMENSION = 45

  GARAGE_KEYWORDS = %w[garage cochera estacionamiento garaje gge gje]

  COMMON_HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language" => "en-US,en;q=0.5"
  }

  private

  def get_info(doc)
    [
      get_title(doc),
      URI::DEFAULT_PARSER.escape(get_href(doc)),
      get_prices(doc)
    ]
  end

  def allowed_price?(prices, card, url)
    return prices.sum <= MAX_PRICE || (prices.sum <= MAX_PRICE + GARAGE_PRICE_INCREASE && garage_on_title?(card)) if prices.size == 2

    response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
    doc = Nokogiri::HTML(response.body)

    prices << get_expenses(doc)
    prices.sum <= MAX_PRICE || (prices.sum <= MAX_PRICE + GARAGE_PRICE_INCREASE && garage_on_page?(doc))
  end

  def garage_on_title?(card)
    title = get_title(card)
    return false unless title.present?

    garage_in_text?(title)
  end

  def garage_on_page?(doc)
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
    puts "Allowed price: #{allowed_price?(get_prices(card), card, URI.join(base_url, safe_href).to_s)}"
    puts "*" * 100
  end
end
