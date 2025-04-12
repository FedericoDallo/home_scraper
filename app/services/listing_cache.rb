class ListingCache
    TTL = 24.hours

    def write(source, url)
      Rails.cache.write(key(source, url), { url:, delete_at: TTL.from_now.iso8601 })
    end

    def read(source, url)
      Rails.cache.read(key(source, url))
    end

    def delete(source, url)
      Rails.cache.delete(key(source, url))
    end

    def clear
      Rails.cache.clear
    end

    def seen?(source, url)
      entry = Rails.cache.read(key(source, url))
      return false if entry.nil?

      Time.parse(entry[:seen_at]) > TTL.ago
    rescue
      false
    end

    def mark_seen(source, url)
      Rails.cache.write(key(source, url), { seen_at: Time.now.iso8601 })
    end

    private

    def key(source, url)
      "#{source} - #{Digest::SHA1.hexdigest(url)}"
    end
  end
  