require 'htmlentities'
require 'liquid'

module JekyllPagesApi
  # This is a hack to allow the module functions to be used
  class Filters
    include Liquid::StandardFilters

    def decode_html(str)
      self.html_decoder.decode(str)
    end

    # Slight tweak of
    # https://github.com/Shopify/liquid/blob/v2.6.1/lib/liquid/standardfilters.rb#L71-L74
    # to replace newlines with spaces.
    def condense(str)
      str.to_s.gsub(/\s+/m, ' '.freeze).strip
    end

    def text_only(str)
      [:strip_html, :condense, :decode_html].each do |filter|
        str = self.send(filter, str)
      end
      str
    end


    private

    def html_decoder
      @html_decoder = HTMLEntities.new
    end
  end
end
