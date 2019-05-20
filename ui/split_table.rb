module Multisplit
  module SplitTable
    def reload_splits
      return if @splits.basic?
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
        best = time == @splits.best[name] || @splits.best[name].nil?
        time = (time_sum += time) unless time.nil? || time == "-"
        comp = (comp_sum += comp) unless comp.nil? || comp == "-"
        time.nil? ? comparison_w_color(comp) : delta_w_color(comp, time, best)
      end
    end

    def comparison_w_color(comp)
      comp = comp.nil? || comp == "-" ? \
        Data.splits["text-when-empty"] : stringify(comp)
      [comp, Data.colors["normal-text"]]
    end

    def delta_w_color(comp, time, best)
      if time == "-"
        delta = Data.splits["text-when-empty"]
        color = Data.colors["normal-text"]
      elsif comp.nil? || comp == "-"
        delta = stringify(time)
        color = Data.colors["new-time"]
      else
        delta = stringify(time - comp, true)
        color = Data.colors[delta[0] == "-" ? "ahead" : "behind"]
      end
      p best
      color = Data.colors["best-seg"] if best
      [delta, color]
    end

    def scroll(array)
      total = Data.splits["total-splits"]
      max = names.length - total
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

    def stringify(time, delta = false)
      sign = time.positive? && delta ? "+" : ""
      before = Data.splits["decimals-before-1-min"] && time < 60
      after  = Data.splits["decimals-after-1-min"] && time >= 60
      decimals = before || after ? 1 : 0
      sign + Timer.stringify(time, Data.splits["leading-zeros"], decimals)
    end
  end
end
