module Multisplit
  class BasicSplits
    attr_reader :timer

    def initialize
      @timer = Timer.new
      reset
    end

    def basic?
      true
    end

    def split
      @timer.start
    end

    def reset
      @timer.reset
    end

    def pause
      @timer.paused? ? @timer.unpause : @timer.pause
    end

    def next
    end

    def prev
    end

    def change_route(num)
    end
  end
end
