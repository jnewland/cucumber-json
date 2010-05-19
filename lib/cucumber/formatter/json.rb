require 'json'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class JSON
      include Io

      FORMATS = Hash.new{|hash, format| hash[format] = method(format).to_proc}

      def initialize(step_mother, path_or_io, options)
        @io = ensure_io(path_or_io, "json")
        @options = options
        @status_counts = Hash.new{|h,k| h[k] = 0}
        @indent = 0
        @hash = {}
      end

      def before_examples(*args)
        @header_row = true
      end

      def before_feature(feature)
        @exceptions = []
        @indent = 0
        @feature = ''
      end

      def feature_name(keyword, name = nil)
        @feature <<  "#{keyword}: #{name}\n"
      end

      def before_feature_element(feature_element)
        @indent = 2
        @element_exceptions = []
        @feature_element = ""
        @scenario_indent = 2
      end

      def before_background(background)
        @indent = 2
        @scenario_indent = 2
        @in_background = true
      end

      def after_background(background)
        @in_background = nil
      end

      def background_name(keyword, name, file_colon_line, source_indent)
        print_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def background_name(keyword, name, file_colon_line, source_indent)
        print_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def before_examples_array(examples_array)
        @indent = 4
        @visiting_first_example_name = true
      end

      def examples_name(keyword, name)
        @feature_element <<  "\n" unless @visiting_first_example_name
        @visiting_first_example_name = false
        names = name.strip.empty? ? [name.strip] : name.split("\n")
        @feature_element <<  "    #{keyword}: #{names[0]}\n"
        names[1..-1].each {|s| @feature_element <<  "      #{s}\n" } unless names.empty?
        @indent = 6
        @scenario_indent = 6
      end

      def before_outline_table(outline_table)
        @table = outline_table
      end

      def after_outline_table(outline_table)
        @table = nil
        @indent = 4
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        print_feature_element_name(keyword, name, file_colon_line, source_indent)
      end

      def before_step(step)
        @current_step = step
        @indent = 6
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        @hide_this_step = false
        if exception
          if @exceptions.include?(exception)
            @hide_this_step = true
            return
          end
          @element_exceptions << exception
          @exceptions << exception
        end
        if status != :failed && @in_background ^ background
          @hide_this_step = true
          return
        end
        @status = status
      end

      def step_name(keyword, step_match, status, source_indent, background)
        return if @hide_this_step
        source_indent = nil unless @options[:source]
        name_to_report = format_step(keyword, step_match, status, source_indent)
        @feature_element <<  name_to_report.indent(@scenario_indent + 2)
        @feature_element <<  "\n"
      end

      def py_string(string)
        return if @hide_this_step
        s = %{"""\n#{string}\n"""}.indent(@indent)
        s = s.split("\n").map{|l| l =~ /^\s+$/ ? '' : l}.join("\n")
        @feature_element <<  format_string(s, @current_step.status)
        @feature_element <<  "\n"
      end

      def exception(exception, status)
        return if @hide_this_step
        print_exception(exception, status, @indent)
      end

      def before_multiline_arg(multiline_arg)
        return if @options[:no_multiline] || @hide_this_step
        @table = multiline_arg
      end

      def after_multiline_arg(multiline_arg)
        @table = nil
      end

      def before_table_row(table_row)
        return if !@table || @hide_this_step
        @col_index = 0
        @feature_element <<  '  |'.indent(@indent-2)
      end

      def after_table_cell(cell)
        return unless @table
        @col_index += 1
      end

      def table_cell_value(value, status)
        return if !@table || @hide_this_step
        status ||= @status || :passed
        width = @table.col_width(@col_index)
        cell_text = value.to_s || ''
        padded = cell_text + (' ' * (width - cell_text.jlength))
        prefix = cell_prefix(status)
        @feature_element <<  ' ' + format_string("#{prefix}#{padded}", status) + ::Term::ANSIColor.reset(" |")
        @feature_element <<  "\n"
      end

      # mine

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        record_result(status, :step_match => step_match)
      end

      def after_table_row(table_row)
        unless @header_row
          record_result(table_row.status) if table_row.respond_to?(:status)
        end
        @header_row = false if @header_row
        return if !@table || @hide_this_step
        print_table_row_announcements
        @feature_element <<  "\n"
        if table_row.exception && !@exceptions.include?(table_row.exception)
          print_exception(table_row.exception, table_row.status, @indent)
        end
      end

      def after_features(steps)
        @hash[:status_counts] = @status_counts
        @io.print(@hash.to_json)
        @io.flush
        @io.close
      end

      def after_feature_element(element)
        @hash[:feature_elements] ||= []
        @hash[:feature_elements] << @feature_element
        @hash[:failing_features] ||= []
        if @element_exceptions.size > 0
          @hash[:failing_features] << @feature_element
        end
        @feature_element = ''
      end

    private

      def record_result(status, opts={})
        step_match = opts[:step_match] || true
        @status_counts[status] = @status_counts[status] + 1
      end

      def print_feature_element_name(keyword, name, file_colon_line, source_indent)
        @feature_element <<  "\n" if @scenario_indent == 6
        names = name.empty? ? [name] : name.split("\n")
        line = "#{keyword}: #{names[0]}".indent(@scenario_indent)
        @feature_element <<  line
        @feature_element <<  "\n"
        names[1..-1].each {|s| @feature_element <<  "    #{s}\n"}
      end

      def print_exception(e, status, indent)
        @feature_element <<  format_string("#{e.message} (#{e.class})\n#{e.backtrace.join("\n")}".indent(indent), status)
        @feature_element <<  "\n"
      end

      def cell_prefix(status)
        @prefixes[status]
      end

      def format_string(string, status)
       string
      end

      def format_step(keyword, step_match, status, source_indent)
        comment = if source_indent
          c = (' # ' + step_match.file_colon_line).indent(source_indent)
          format_string(c, :comment)
        else
          ''
        end

        if status == :passed
          line = keyword + ' ' + step_match.format_args(nil)
          format_string(line, status)
        else
          line = keyword + ' ' + step_match.format_args(nil) + comment
          format_string(line, status)
        end
      end

    end
  end
end