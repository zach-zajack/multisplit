module Multisplit
  module Metadata
    def reload_metadata
      @metadata.clear do
        prev_seg_best if Data.metadata["show-prev-seg-against-best"]
        pos_timesave  if Data.metadata["show-possible-timesave"]
        sum_of_best   if Data.metadata["show-sum-of-best"]
      end
    end

    def prev_seg_best
      prev = @splits.prev_name
      prev_best = @splits.bests[prev]
      prev_time = @splits.live_times[prev]
      best = !(prev_best.nil? || prev_time.nil? \
        || prev_time == "-" || prev_best < prev_time)
      colorized = colorize_delta(prev_best, prev_time, best)
      flow do
        para "Prev. segment:", margin: 5
        para colorized.first,  margin: 5, stroke: colorized.last
      end
    end

    def pos_timesave
      name = @splits.name
      best = @splits.bests[name]
      comp = @splits.times[name]
      diff = best.nil? || @splits.index.negative? || comp.nil? ? \
        Data.splits["text-when-empty"] : stringify(comp - best)
      para "Possible timesave: #{diff}", margin: 5
    end

    def sum_of_best
      para "Sum of best: #{@splits.sum_of_best}", margin: 5
    end
  end
end
