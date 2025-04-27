class CheckAll
  def initialize
    @scrapers = [
      InfoCasasScraper,
      MercadoLibreScraper,
      RemaxScraper,
      HousiScraper,
      SorhuetScraper
    ]
  end

  def run(debugging_mode = false)
    notifier = Notifier.new
    cache = ListingCacheJson.new
    @scrapers.each do |scraper|
      name = scraper::NAME
      scraper.new.fetch_listings(debugging_mode).each do |result|
        result => { title: message, url: }
        if cache.read(name, url)
          puts "Already seen: #{url}"
        else
          unless debugging_mode
            cache.write(name, url)
            notifier.send(title: "Nuevo apto en #{name.titleize}", message:, url:)
          end
          puts "New listing: #{url}"
        end
      end
    end

  rescue => e
    debugging_mode ? puts(e.message) : notifier.send_error(e)
  end
end
