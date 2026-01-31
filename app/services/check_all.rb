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
    users = UsersConfig.load
    bounds = users.any? ? UsersConfig.bounds_from_users(users) : UsersConfig.default_bounds

    (@scrapers + @apis).map do |scraper_class|
      name = scraper_class::NAME
      scraper = scraper_class.new
      scraper.bounds = bounds
      listings = scraper.fetch_listings(mode)

      listings.each do |result|
        result => { title: message, url: }
        if cache.read(name, url)
          puts "Already seen: #{url}"
        else
          if mode == NORMAL_MODE
            cache.write(name, url)
            recipients = users.any? ? users.select { |u| listing_passes_user_filters?(result, u) } : [nil]
            recipients.each do |user|
              notifier.send(
                title: "Nuevo apto en #{name.to_s.titleize}",
                message: message,
                url: url,
                user_key: user&.pushover_user_key
              )
            end
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

  private

  def listing_passes_user_filters?(listing, user)
    return true if user.nil?

    total_price = listing_total_price(listing)
    has_garage = listing_has_garage?(listing)
    max = user.max_price || UsersConfig::DEFAULT_FILTERS[:max_price]
    garage_inc = user.garage_price_increase || UsersConfig::DEFAULT_FILTERS[:garage_price_increase]

    total_price <= max || (total_price <= max + garage_inc && has_garage)
  end

  def listing_total_price(listing)
    if listing.key?(:price) && listing.key?(:expenses)
      (listing[:price].to_i + listing[:expenses].to_i)
    elsif listing[:prices].is_a?(Array)
      listing[:prices].sum
    else
      listing[:prices].to_i
    end
  end

  def listing_has_garage?(listing)
    return true if listing[:garage_on_title]
    return (listing[:garages].to_i > 0) if listing.key?(:garages)

    false
  end
end
