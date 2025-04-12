class CheckAll
  def initialize
    @scrapers = [
      InfoCasasScraper.new
    ]
  end
  
  def run
    cache = ListingCache.new
    @scrapers.each do |scraper|
      name = scraper.class::NAME
      scraper.fetch_listings.each do |result|
        if cache.read(name, result[:url])
          puts "Already seen: #{result[:url]}"
        else
          cache.write(name, result[:url])
          puts "New listing: #{result[:url]}"
        end
      end
    end
  end
end
