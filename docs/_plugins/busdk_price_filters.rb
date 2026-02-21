# frozen_string_literal: true

module Jekyll
  module BusdkPriceFilters
    # Formats a numeric EUR amount as a rounded integer with space thousands,
    # e.g. 31713.44 -> "31 713".
    def eur_rounded(value)
      number = begin
        Float(value)
      rescue StandardError
        return value.to_s
      end
      rounded = number.round
      text = rounded.to_s
      negative = text.start_with?("-")
      digits = negative ? text[1..] : text
      grouped = digits.reverse.scan(/\d{1,3}/).join(" ").reverse
      negative ? "-#{grouped}" : grouped
    end
  end
end

Liquid::Template.register_filter(Jekyll::BusdkPriceFilters)
