require 'yaml'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class Scout
      include Io

      def initialize(step_mother, path_or_io, options)
        @io = ensure_io(path_or_io, "scout")
        @options = options
        @status_counts = Hash.new{|h,k| h[k] = 0}
        @hash = {}
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        record_result(status, :step_match => step_match)
      end

      def before_examples(*args)
        @header_row = true
      end

      def after_table_row(table_row)
        unless @header_row 
          record_result(table_row.status) if table_row.respond_to?(:status)
        end
        @header_row = false if @header_row
      end

      def after_features(steps)
        @hash[:status_counts] = @status_counts
        @io.print(@hash.to_yaml)
        @io.flush
        @io.close
      end

    private

      def record_result(status, opts={})
        step_match = opts[:step_match] || true
        @status_counts[status] = @status_counts[status] + 1
      end

    end
  end
end