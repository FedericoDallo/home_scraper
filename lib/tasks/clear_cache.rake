namespace :clear_cache do
  desc "Borra entradas de cache JSON más viejas que 24 horas"
  task clean_old: :environment do
    require 'time'

    path = ENV.fetch("CACHE_DIR", "cache_data")
    ttl = 24.hours.ago
    deleted = 0

    Dir.glob("#{path}/*.json").each do |file|
      data = JSON.parse(File.read(file))
      data.reject! do |_, entry|
        Time.parse(entry["seen_at"]) < ttl rescue false
      end

      File.write(file, JSON.pretty_generate(data))
      deleted += 1
    end

    puts "✅ Limpieza completa. Archivos procesados: #{deleted}"
  end
end
