# frozen_string_literal: true

module ScraperCommon
  def parse_css_class(text)
    text.split(" ").map { |s| "." + s }.join(",")
  end
  module ClassMethods

    def clean_text(text)
      return if text.nil?
      text.strip.gsub(/\s+/, " ")
    end

    def build_full_url(base_url, path)
      URI.join(base_url, path.split("#").first).to_s
    end
  end

  def garage_in_text?(text)
    garage_keywords.any? { |kw| text.downcase.include?(kw) }
  end

  def garage_keywords
    %w[garage cochera estacionamiento garaje gge gje]
  end

  def get_price_number(text)
    text.gsub(/\D/, '').to_i
  end
end 