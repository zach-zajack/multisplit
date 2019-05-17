module Multisplit
  module Data
    class << self
      attr_reader :window, :splits, :timer, :colors, :hotkeys

      def reload
        data = YAML.load(File.read("settings.yaml"))
        @window  = data["window"]
        @splits  = data["splits"]
        @timer   = data["timer"]
        @colors  = data["colors"]
        @hotkeys = data["hotkeys"]
      end
    end
  end
end
