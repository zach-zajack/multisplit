module Multisplit
  module Times
    def display_timer
      @timer.replace(stringify(@splits.timer.time, false, true))
    end

    def stringify(time, delta = false, timer = false)
      positive_prefix = delta ? "+" : ""
      sign = time.negative? ? "-" : positive_prefix
      time = time.abs
      dec  = decimals(timer, time)
      str  = Time.at(time).utc.strftime("%H:%M:%S.%#{dec}N")
      str.sub!(/\..*$/, "") if dec.zero?
      sign + (Data.splits["leading-zeros"] ? str : str.sub!(/^[0:]{1,7}/, ""))
    end

    def colorize_comparison(comp)
      comp = comp.nil? || comp == "-" ? \
        Data.splits["text-when-empty"] : stringify(comp)
      [comp, Data.colors["normal-text"]]
    end

    def colorize_delta(comp, time, best)
      if time == "-" || time.nil?
        delta = Data.splits["text-when-empty"]
        color = Data.colors["normal-text"]
      elsif comp.nil? || comp == "-"
        delta = stringify(time)
        color = Data.colors["new-time"]
      else
        delta = stringify(time - comp, true)
        color = Data.colors[delta[0] == "-" ? "ahead" : "behind"]
      end
      color = Data.colors["best-seg"] if best
      [delta, color]
    end

    private

    def decimals(timer, time)
      if timer
        return Data.timer["decimals"]
      else
        before = Data.splits["decimals-before-1-min"] && time < 60
        after  = Data.splits["decimals-after-1-min"] && time >= 60
        return before || after ? 1 : 0
      end
    end
  end
end
