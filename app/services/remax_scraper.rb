require 'httparty'
require 'nokogiri'
require 'uri'

class RemaxScraper
  BASE_URL = "https://www.remax.com.uy"
  SEARCH_URL = "https://www.remax.com.uy/listings/rent?page=0&pageSize=50&sort=-createdAt&in:operationId=2&in:eStageId=0,1,2,3,4&in:typeId=1,2,3,4,5,6,7,8&pricein=3:0:35000&gte:dimensionCovered=45&locations=in:::1441@%3Cb%3EPocitos%3C%2Fb%3E::::"

  NAME = "remax"

  def fetch_listings
    response = HTTParty.get(SEARCH_URL, headers: { "User-Agent" => "Mozilla/5.0" })
    doc = Nokogiri::HTML(response.body)

    doc.css("qr-card-property").map do |card|
      # 🛑 Omitir si contiene "Reservada"
      tag_text = card.at_css("qr-tag p")&.text&.strip
      next if tag_text&.downcase == "reservada"

      anchor = card.at_css("a.card-remax__href")
      next unless anchor && anchor["href"]

      full_url = URI.join(BASE_URL, anchor["href"].split("#").first).to_s
      title = card.at_css("p.card__description")&.text&.strip ||
              anchor.text.strip.gsub(/\s+/, " ")

      { title:, url: full_url }
    end.compact.uniq { |l| l[:url] }
  end
end
