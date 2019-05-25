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
      @splits = Splits.new(self, path)
      Data.save_to_config(splits: path)
      @body.clear { body }
      reload_splits
    end

    def open_settings(path)
      return if path.nil?
      Data.open_settings(path)
      Multisplit.open_app
      close
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
        @head = para @splits.metadata["title"], align: "center"
        flow do
          @names = stack width: 0.5, wrap: "trim"
          @col1 = stack width: 0.25
          @col2 = stack width: 0.25
        end
        timer
        @metadata = stack
      end
    end

    def timer
      @timer = title align: "right"
    end
  end
end
