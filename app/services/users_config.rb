# frozen_string_literal: true

require "yaml"

UserConfig = Struct.new(:id, :pushover_user_key, :filters, keyword_init: true) do
  def max_price
    (filters || {})["max_price"] || (filters || {})[:max_price]
  end

  def min_dimension
    (filters || {})["min_dimension"] || (filters || {})[:min_dimension]
  end

  def garage_price_increase
    (filters || {})["garage_price_increase"] || (filters || {})[:garage_price_increase]
  end
end

class UsersConfig
  DEFAULT_FILTERS = {
    max_price: 38_000,
    min_dimension: 45,
    garage_price_increase: 4_500
  }.freeze

  def self.load
    path = Rails.root.join("config", "users.yml")
    return [] unless File.exist?(path)

    data = YAML.load_file(path)
    users = data.is_a?(Hash) ? data["users"] : data
    return [] unless users.is_a?(Array)

    users.filter_map do |h|
      next if h.blank?

      UserConfig.new(
        id: h["id"] || h[:id],
        pushover_user_key: h["pushover_user_key"] || h[:pushover_user_key],
        filters: (h["filters"] || h[:filters] || {}).symbolize_keys
      )
    end
  end

  def self.bounds_from_users(users)
    return default_bounds if users.blank?

    max_price = users.map { |u| u.max_price || DEFAULT_FILTERS[:max_price] }.max
    min_dimension = users.map { |u| u.min_dimension || DEFAULT_FILTERS[:min_dimension] }.min
    garage = users.map { |u| u.garage_price_increase || DEFAULT_FILTERS[:garage_price_increase] }.max

    ScraperBounds.new(
      max_price: max_price,
      min_dimension: min_dimension,
      garage_price_increase: garage
    )
  end

  def self.default_bounds
    ScraperBounds.new(
      max_price: DEFAULT_FILTERS[:max_price],
      min_dimension: DEFAULT_FILTERS[:min_dimension],
      garage_price_increase: DEFAULT_FILTERS[:garage_price_increase]
    )
  end
end

ScraperBounds = Struct.new(:max_price, :min_dimension, :garage_price_increase, keyword_init: true)
