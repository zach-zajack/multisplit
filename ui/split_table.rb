module Multisplit
  module SplitTable
    def reload_splits_table
      @names.clear do
        scroll(names).each do |name, color|
          para name, margin: 5, stroke: color
        end
      end
      @col1.clear { col(1) }
      @col2.clear { col(2) }
    end

    private

    def col(n)
      times = case Data.splits["col#{n}"]
      when "delta"              then times { |*args| delta(*args) }
      when "current"            then times { |*args| current(*args) }
      when "comparison"         then times { |*args| comparison(*args) }
      when "delta/comparison"   then times { |*args| delta_comparison(*args) }
      when "current/comparison" then times { |*args| current_comparison(*args) }
      end
      scroll(times).each do |time, color|
        para time, margin: 5, stroke: color, align: "right"
      end
    end

    def names
      @splits.route.names.map.with_index do |name, i|
        [name, @splits.index == i ? \
          Data.colors["highlight"] : Data.colors["normal-text"]]
      end
    end

    def times(&block)
      time_sum = 0
      comp_sum = 0
      @splits.route.names.map do |name|
        time = @splits.live_times[name]
        comp = @splits.comp[name]
        best = time == @splits.live_bests[name] || @splits.bests[name].nil?
        time = (time_sum += time) unless time.nil? || time == "-"
        comp = (comp_sum += comp) unless comp.nil? || comp == "-"
        block.call(comp, time, best)
      end
    end

    def delta(comp, time, best)
      colorize_delta(comp, time, best)
    end

    def current(comp, time, best)
      colorize_comparison(time)
    end

    def comparison(comp, time, best)
      colorize_comparison(comp)
    end

    def delta_comparison(comp, time, best)
      time.nil? ? colorize_comparison(comp) : colorize_delta(comp, time, best)
    end

    def current_comparison(comp, time, best)
      time.nil? ? colorize_comparison(comp) : colorize_comparison(time)
    end

    def scroll(array)
      total = Data.splits["total-splits"]
      max = names.length - total
      max = 0 unless max.positive?
      prev_shown = total - Data.splits["upcoming-splits"]

      hidden = @splits.index - prev_shown
      hidden = 0 if hidden.negative?
      hidden = max if hidden > max

      if Data.splits["lock-last-split"] && max.positive?
        return array[hidden, total - 1] << array[-1]
      else
        return array[hidden, total]
      end
    end
  end
end
