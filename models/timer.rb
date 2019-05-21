module Multisplit
  class Timer
    def initialize(offset = 0)
      @offset = offset
      reset
    end

    def start
      return unless reset?
      @start_time = now - @offset
      @state = :running
    end

    def reset
      @start_time = -@offset
      @pause_time = 0
      @state = :reset
    end

    def pause
      return unless running?
      @state = :paused
      @pause_time = now
    end

    def unpause
      return unless paused?
      @state = :running
      @start_time += pause_elapse_time
    end

    def undo_pause
      @state = :running
    end

    def paused?
      @state == :paused
    end

    def reset?
      @state == :reset
    end

    def running?
      @state == :running
    end

    def counting_down?
      time.negative? || reset?
    end

    def time
      (running? ? now : @pause_time) - @start_time
    end

    private

    def pause_elapse_time
      now - @pause_time
    end

    def now
      # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
