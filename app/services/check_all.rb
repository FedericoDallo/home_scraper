class CheckAll
  def initialize
    @scrapers = [
      InfoCasasScraper.new
    ]
  end
  
  def run
    notifier = Notifier.new
    cache = ListingCacheJson.new
    @scrapers.each do |scraper|
      name = scraper.class::NAME
      scraper.fetch_listings.each do |result|
        result => { title: message, url: }
        if cache.read(name, url)
          puts "Already seen: #{url}"
        else
          cache.write(name, url)
          notifier.send(title: "Nuevo apto en #{name.titleize}", message:, url:)
          puts "New listing: #{url}"
        end
      end
    end
  end
end
