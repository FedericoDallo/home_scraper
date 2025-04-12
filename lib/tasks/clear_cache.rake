namespace :clear_cache do
    desc "Borra archivos de file_store más viejos que 24 horas"
    task clean_old: :environment do
      cutoff = 24.hours.ago
      path = Rails.root.join("tmp/cache/listing_cache")
  
      Dir.glob("#{path}/**/*").each do |file|
        next unless File.file?(file)
        # debugger
        if File.mtime(file) < cutoff
          File.delete(file)
          puts "🧽 Borrado #{file}"
        end
      end
  
      puts "✅ Limpieza completa"
    end
  end
  