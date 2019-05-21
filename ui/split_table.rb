module Multisplit
  module SplitTable
    def reload_splits_table
      @names.clear do
        scroll(names).each do |name, color|
          para name, margin: 5, stroke: color
        end
      end
      @times.clear do
        scroll(times).each do |time, color|
          para time, margin: 5, stroke: color, align: "right"
        end
      end
    end

    private

    def names
      @splits.route.names.map.with_index do |name, i|
        [name, @splits.index == i ? \
          Data.colors["highlight"] : Data.colors["normal-text"]]
      end
    end

    def times
      time_sum = 0
      comp_sum = 0
      @splits.route.names.map do |name|
        time = @splits.times[name]
        comp = @splits.pb[name]
        best = time == @splits.best_temp[name] || @splits.best[name].nil?
        time = (time_sum += time) unless time.nil? || time == "-"
        comp = (comp_sum += comp) unless comp.nil? || comp == "-"
        time.nil? ? colorize_comparison(comp) : colorize_delta(comp, time, best)
      end
    end

    def scroll(array)
      total = Data.splits["total-splits"]
      max = names.length - total
      prev_shown = total - Data.splits["upcoming-splits"]

      hidden = @splits.index - prev_shown
      hidden = 0 if hidden.negative?
      hidden = max if hidden > max

      if Data.splits["lock-last-split"]
        return array[hidden, total - 1] << array[-1]
      else
        return array[hidden, total]
      end
    end
  end
end
