module Multisplit
  class Splits < BasicSplits
    attr_reader :names, :route, :metadata, :pb, :best, :index, :times

    def initialize(path = nil)
      @splits   = YAML.load(File.read(path))
      @names    = @splits["names"]
      @route    = Route.new(@splits["route"])
      @metadata = @splits["metadata"]
      @pb       = @splits["personal-best"] || {}
      @best     = @splits["sum-of-best"]   || {}
      @timer    = Timer.new(@metadata["offset (sec)"])
      reset
    end

    def basic?
      false
    end

    def split
      return if @finished
      add_time unless @timer.counting_down?
      @index = 0 if @timer.reset?
      @index < @route.total_length ? super : finish
    end

    def finish
      @timer.pause
      @finished = true
    end

    def set_pb
      @pb = @times if @pb == {} || sum(@pb) > sum(@times)
    end

    def prev
      return if @index <= 0
      if @finished
        @timer.undo_pause
        @finished = false
      end
      @index -= 1
      @times.delete(name)
      @best.delete(name)
    end

    def next
      return if @timer.counting_down? || @index + 1 >= @route.total_length
      @times[name] = "-"
      @index += 1
    end

    def reset
      set_pb if @finished
      @index = -1
      @times = {}
      @route.reset
      @metadata["resets"] += 1 unless @timer.counting_down?
      @finished = false
      super
    end

    def change_route(num)
      @route.switch(@index, num - 1)
    end

    def sum(times)
      total = 0
      times.each { |name, time| total += time unless time == "-" }
      return total
    end

    def sum_of_best
      sob = sum(@best)
      sob == 0 ? "none" : stringify(sob)
    end

    def save
      @splits.merge(
        "metadata" => @metadata,
        "personal-best" => @pb,
        "sum-of-best" => @best)
    end

    private

    def name
      @route.names[@index]
    end

    def add_time
      il_time = (@timer.time - sum(@times)).round(2)
      @times[name] = il_time
      @best[name] = il_time if @best[name].nil? || @best[name] > il_time
      @index += 1
    end
  end
end
