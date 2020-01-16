module Slcsp
  require 'csv'

  class IdentifyPlan
    def initialize
      @plans = CSV.read("vendor/plans.csv", headers: true)
      @zips = CSV.read("vendor/zips.csv", headers: true)
      @slcsp = CSV.read("vendor/slcsp.csv", headers: true)
      @output_file = "vendor/slcsp-with-rates.csv"
    end

    def find_slcsp
      output = Array.new
      @slcsp.each do |slcsp|
        area = get_area(slcsp['zipcode'])
        if area
          rates = get_silver_rates(area['rate_area'], area['state'])
          slcsp['rate'] = get_second_lowest_rate(rates)
        end
        output << slcsp
      end
      write_to_csv output
    end

    private

    def get_area zipcode
      area = @zips.find_all { |row| row['zipcode'] == zipcode }
      area.uniq{|x| x['rate_area']}.count > 1 ? false : area.first
    end

    def get_silver_rates area, state
      area_rates = @plans.find_all { |row| row['rate_area'] == area && row['state'] == state }
      area_rates.reject { |r| r['metal_level'] != 'Silver' }
    end

    def get_second_lowest_rate rates
      if rates
        sorted_rates = rates.count > 1 ? rates.sort_by { |row| row['rate'].to_f } : nil
        sorted_rates[1]['rate'] unless sorted_rates.nil?
      end
    end

    def write_to_csv output
      output.unshift %w(zipcode rate)
      File.open(@output_file, "w") {|f| f.write(output.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}
    end
  end

end
