require 'json'
require 'fileutils'
require 'digest/sha1'
require 'time'

class ListingCacheJson
  TTL = 24.hours

  def initialize(cache_dir: ENV.fetch("CACHE_DIR", "cache_data"))
    @source_cache = {}
    @cache_dir = cache_dir
    FileUtils.mkdir_p(@cache_dir)
  end

  def write(source, url)
    load_source(source)
    data = { url: url, delete_at: TTL.from_now.iso8601 }
    @source_cache[source][key(source, url)] = data
    save_source(source)
  end

  def read(source, url)
    load_source(source)
    @source_cache[source][key(source, url)]
  end

  def delete(source, url)
    load_source(source)
    @source_cache[source].delete(key(source, url))
    save_source(source)
  end

  def clear
    FileUtils.rm_rf(@cache_dir)
    FileUtils.mkdir_p(@cache_dir)
    @source_cache.clear
  end

  def seen?(source, url)
    load_source(source)
    entry = @source_cache[source][key(source, url)]
    return false if entry.nil?
    Time.parse(entry[:seen_at]) > TTL.ago
  rescue
    false
  end

  def mark_seen(source, url)
    load_source(source)
    @source_cache[source][key(source, url)] = { seen_at: Time.now.iso8601 }
    save_source(source)
  end

  private

  def key(source, url)
    "#{source} - #{Digest::SHA1.hexdigest(url)}"
  end

  def load_source(source)
    return if @source_cache[source]

    file = path_for(source)
    if File.exist?(file)
      @source_cache[source] = JSON.parse(File.read(file))
    else
      @source_cache[source] = {}
    end
  end

  def save_source(source)
    File.write(path_for(source), JSON.pretty_generate(@source_cache[source]))
  end

  def path_for(source)
    File.join(@cache_dir, "#{source}_cache.json")
  end
end
