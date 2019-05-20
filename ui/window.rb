module Multisplit
  module Window
    def open_basic
      @splits = BasicSplits.new
      @body.clear
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
        @head = para @splits.metadata["title"], \
          margin_top: 15, align: "center"
        flow do
          @names = stack width: 0.7, margin_left: 20
          @times = stack width: 0.3, margin_right: 30
        end
      end
    end
  end
end