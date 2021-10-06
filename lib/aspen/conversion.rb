require 'csv'

module Aspen
  # Helps convert non-Aspen into Aspen
  # before compiling Aspen into other code.
  module Conversion
    class Builder
      def initialize(args = {})
        @from_format = args[:format]
        @from_file   = args[:file]
        @csv_options = { headers: true }
      end

      def csv(path)
        @from_format = :csv
        @from_path   = path
        self
      end

      def tsv(path)
        @from_format = :csv
        @from_path   = path
        @csv_options[:col_sep] = "\t"
        self
      end

      def to_aspen(&block)
        file  = CSV.open(@from_path, @csv_options)
        aspen = File.open(@from_path.rpartition(".").first + ".aspen", 'w')
        yield file, aspen
      ensure
        aspen.close
      end
    end
  end

  # @example
  #   Aspen.convert.csv('path/to/csv').to_aspen
  def self.convert
    Aspen::Conversion::Builder.new({})
  end

end
