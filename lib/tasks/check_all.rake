namespace :check do
    desc "Run all scrapers and notify new listings"
    task all: :environment do
      CheckAll.new.run
    end
  end
  