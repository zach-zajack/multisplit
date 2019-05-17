module Multisplit
  class Timer
    def self.stringify(time, leading_zeros, decimals)
      sign = time < 0 ? "-" : ""
      time = time.abs
      str = Time.at(time).utc.strftime("%H:%M:%S.%#{decimals}N")
      str.sub!(/\..*$/, "") if decimals == 0
      leading_zeros ? sign + str : sign + str.sub!(/^[0:]{1,7}/, "")
    end

    def initialize(offset = 0)
      @offset = offset
      reset
    end

    def start
      return unless @paused
      @start_time = now - @offset
      @paused = false
    end

    def reset
      @start_time = -@offset
      @pause_time = 0
      @paused = true
    end

    def pause
      @paused = true
      @pause_time = now
    end

    def unpause
      @paused = false
      @start_time += pause_elapse_time
    end

    def paused?
      @paused
    end

    def time
      (@paused ? @pause_time : now) - @start_time
    end

    def display
      Timer.stringify(time, Data.timer["leading-zeros"], Data.timer["decimals"])
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
