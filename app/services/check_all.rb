class CheckAll
  def initialize
    @scrapers = [
      InfoCasasScraper,
      MercadoLibreScraper,
      RemaxScraper,
      HousiScraper,
      SorhuetScraper
    ]

    @apis = [
      ImperiumInmobiliaria,
      InfoCasasApiScraper
    ]
  end

  def run(mode = NORMAL_MODE)
    notifier = Notifier.new
    cache = ListingCacheJson.new
    (@scrapers + @apis).map do |scraper|
      name = scraper::NAME
      listings = scraper.new.fetch_listings(mode)
      listings.each do |result|
        result => { title: message, url: }
        if cache.read(name, url)
          puts "Already seen: #{url}"
        else
          if mode == NORMAL_MODE
            cache.write(name, url)
            notifier.send(title: "Nuevo apto en #{name.titleize}", message:, url:)
          end
          puts "New listing: #{url}"
        end
      end

      [name.to_sym, listings]
    end.to_h

  rescue => e
    case mode
    when NORMAL_MODE
      notifier.send_error(e)
    when DEBUGGING_MODE
      debugger
    when LOG_MODE
      puts e.message
    end
  end
end
