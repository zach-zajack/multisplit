module Multisplit
  class Splits < BasicSplits
    attr_reader :index, :route, :metadata

    def initialize(path = nil)
      @splits = YAML.load(File.read(path))
      @names  = @splits["names"]
      @route  = Route.new(@splits["route"])
      @metadata = @splits["metadata"]
      @pb  = @splits["personal-best"] || {}
      @sob = @splits["sum-of-best"] || {}
      @timer = Timer.new(@metadata["offset (sec)"])
      reset
    end

    def basic?
      false
    end

    def split
      return if @finished
      add_time if @timer.time > 0
      @index = 0 if @index == -1
      @index < @route.length ? super : finish
    end

    def finish
      @timer.pause
      @finished = true
      last_split = @route.names[-1]
      @pb = @times if @pb == {} || @pb[last_split] > @times[last_split]
    end

    def prev
      return if @index <= 0
      if @finished
        @timer.unpause
        @finished = false
      end
      @index -= 1
      @times.delete(@route.names[@index])
    end

    def next
      return if @finished
      @index += 1
    end

    def reset
      @sum = 0
      @index = -1
      @times = {}
      @route.reset
      @finished = false
      super
    end

    def change_route(num)
      @route.switch(@index, num - 1)
    end

    def names
      @route.names.map.with_index do |name, i|
        if @index == i
          [name, Data.colors["highlight"]]
        else
          [name, Data.colors["normal-text"]]
        end
      end
    end

    def times
      time_sum = 0
      comp_sum = 0
      @route.names.map do |name|
        time = @times[name]
        comp = @pb[name]
        best = time == @sob[name]
        time = (time_sum += time) unless time.nil?
        comp = (comp_sum += comp) unless comp.nil?
        time.nil? ? comparison_color(comp) : delta_color(comp, time, best)
      end
    end

    def comparison_color(comp)
      comp = comp.nil? ? Data.splits["text-when-empty"] : stringify(comp)
      [comp, Data.colors["normal-text"]]
    end

    def delta_color(comp, time, best)
      if comp.nil?
        delta = stringify(time)
        color = Data.colors["new-time"]
      else
        delta = stringify(time - comp, true)
        color = Data.colors[delta[0] == "-" ? "ahead" : "behind"]
      end
      color = Data.colors["best-seg"] if best
      [delta, color]
    end

    def save
      @splits.merge("personal-best" => @pb, "sum-of-best" => @sob)
    end

    private

    def add_time
      il_time = (@timer.time - @sum).round(2)
      name = @route.names[@index]
      @times[name] = il_time unless @index == -1
      @sob[name] = il_time if @sob[name].nil? || @sob[name] > il_time
      @sum += il_time
      @index += 1
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
