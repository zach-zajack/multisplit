module Multisplit
  module Window
    def reload_splits
      return if @splits.basic?
      @names.clear do
        scroll(@splits.names).each do |name, color|
          para name, margin: 5, stroke: color
        end
      end
      @times.clear do
        scroll(@splits.times).each do |time, color|
          para time, margin: 5, stroke: color, align: "right"
        end
      end
    end

    def open_basic
      @splits = BasicSplits.new
      @body.clear
    end

    def open_splits(path)
      return if path.nil?
      Data.save_to_config(splits: path)
      @path = path
      @splits = Splits.new(@path)
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

    def scroll(array)
      total = Data.splits["total-splits"]
      max = @splits.names.length - total
      prev_shown = total - Data.splits["upcoming-splits"]

      hidden = @splits.index - prev_shown
      hidden = 0 if hidden < 0
      hidden = max if hidden > max

      if Data.splits["lock-last-split"]
        return array[hidden, total - 1] << array[-1]
      else
        return array[hidden, total]
      end
    end

    def body
      stack do
        height = Data.splits["total-splits"] * 28
        @head = para @splits.metadata["title"], \
          margin_top: 15, align: "center"
        flow do
          @names = stack width: 0.7, height: height, margin_left: 20
          @times = stack width: 0.3, height: height, margin_right: 30
        end
      end
    end
  end
end
