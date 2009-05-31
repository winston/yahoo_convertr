require 'rubygems'
require 'hpricot'

module YahooFinance

  class CurrencyConverter

    def initialize(date=Date.today)

      # XML Request
      opt  = date == Date.today ? "" : "date=#{date.strftime("%Y%m%d")}"
      api  = "http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote;#{opt};currency=true?view=basic"
      uri  = URI.parse(api)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = http.open_timeout = 20

      response = http.start { http.request(Net::HTTP::Get.new(uri.to_s)) }
      doc      = Hpricot.parse(response.body)

      # Rates Object
      @usd_rates = { "USD" => 1.0 }

      (doc/:resource).each do |resource|

        symbol = resource.search("[@name=symbol]").inner_html[0,3]
        price  = resource.search("[@name=price]").inner_html

        @usd_rates[symbol.upcase] = price.to_f unless symbol.nil? && price.nil?

      end

    end

    def convert(amount, base, quot)

        base_rate = @usd_rates[base.upcase]
        quot_rate = @usd_rates[quot.upcase]

        return amount * (quot_rate/base_rate)

    end

  end

end