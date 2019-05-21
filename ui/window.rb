module Multisplit
  module Window
    def reload_splits
      reload_splits_table
      reload_metadata
    end

    def open_basic
      @splits = BasicSplits.new
      @body.clear { timer }
    end

    def open_splits(path)
      return if path.nil?
      Data.save_to_config(splits: path)
      @path = path
      @splits = Splits.new(self, @path)
      @body.clear { body }
      reload_splits
    end

    def open_settings(path)
      return if path.nil?
      Data.open_settings(ask_open_file)
    end

    def save_splits(path)
      return if path.nil?
      File.open(path, "w") { |f| f.write(YAML.dump(@splits.save)) }
    end

    def split_info
      "Sum of Best: #{@splits.sum_of_best}\n" \
      "Reset Count: #{@splits.metadata['resets']}"
    end

    def body
      stack do
        @head = para @splits.metadata["title"], margin_top: 15, align: "center"
        flow do
          @names = stack width: 0.5, margin_left: 20
          @col1 = stack width: 0.2
          @col2 = stack width: 0.3, margin_right: 30
        end
        timer
        @metadata = stack margin_left: 20
      end
    end

    def timer
      @timer = title margin_right: 30, align: "right"
    end
  end
end
