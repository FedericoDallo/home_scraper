source "https://rubygems.org"

# Framework base
gem "rails", "~> 8.0.2"

# Base de datos local (opcional, para desarrollo/test)
gem "sqlite3", ">= 2.1"

# Scraping
gem 'httparty', '~> 0.23.1'
gem 'nokogiri', '~> 1.18'

# Servidor web
gem "puma"

# Jobs y cache simples
gem "solid_cache"
gem "solid_queue"

# Mejor arranque
gem "bootsnap", require: false

# Compatibilidad con WSL/Windows
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  # Debug interactivo
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end
