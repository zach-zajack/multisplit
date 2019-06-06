module Multisplit
  class Splits < BasicSplits
    attr_reader :names, :route, :metadata, :path, \
      :times, :bests, :index, :live_times, :live_bests

    def initialize(app, path = nil)
      @app    = app
      @path   = path
      @splits = YAML.load(File.read(path))
      @names  = @splits["names"]
      @route  = Route.new(@splits["route"])
      @times  = @splits["personal-best"] || {}
      @bests  = @splits["sum-of-best"]   || {}
      @metadata = @splits["metadata"]
      @timer  = Timer.new(@metadata["offset (sec)"])
      @display_best = false
      reset
    end

    def basic?
      false
    end

    def split
      @app.reset_scroll
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
      @times = @live_times if @times.empty? || sum(@times) > sum(@live_times)
    end

    def prev
      return if @index <= 0
      if @finished
        @timer.undo_pause
        @finished = false
      end
      @index -= 1
      @live_times.delete(name)
      @live_bests.delete(name)
    end

    def next
      return if @timer.counting_down? || @index + 1 >= @route.total_length
      @live_times[name] = "-"
      @index += 1
    end

    def reset
      set_pb if @finished
      @index = -1
      @live_times = {}
      @bests.merge!(@live_bests) if @live_bests&.any? && \
        @app.confirm("Do you want to save your best segments?")
      @live_bests = {}
      @route.reset
      @metadata["resets"] += 1 unless @timer.counting_down?
      @finished = false
      super
    end

    def change_route(num)
      @route.switch(@index, num - 1)
    end

    def toggle_best
      @display_best = !@display_best
    end

    def comp
      @display_best ? @bests : @times
    end

    def sum(times)
      total = 0
      times.each { |name, time| total += time unless time == "-" }
      return total
    end

    def sum_of_best
      merged = @bests.merge(@live_bests) unless @bests.nil?
      merged.nil? || merged.include?("-") ? \
        Data.splits["text-when-empty"] : @app.stringify(sum(merged))
    end

    def save
      @splits.merge(
        "metadata" => @metadata,
        "personal-best" => @times,
        "sum-of-best" => @bests)
    end

    def name
      @route.names[@index]
    end

    def prev_name
      @route.names[@index - 1] unless @index.negative?
    end

    private

    def add_time
      il_time = (@timer.time - sum(@live_times)).round(2)
      @live_times[name] = il_time
      @live_bests[name] = il_time if @bests[name].nil? || @bests[name] > il_time
      @index += 1
    end
  end
end
