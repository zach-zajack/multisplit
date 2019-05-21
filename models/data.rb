module Multisplit
  module Data
    class << self
      attr_reader :app_data, \
        :window, :splits, :timer, :colors, :hotkeys, :metadata

      BASEDIR = "#{RUBY_PLATFORM =~ /linux/ ? '.multisplit' : 'Multisplit'}"
      APPDIR  = File.expand_path("../#{BASEDIR}", LIB_DIR)
      APPFILE = File.join(APPDIR, "config.yaml")

      def init_app_data
        @app_data = File.exist?(APPFILE) ? YAML.load(File.read(APPFILE)) : {}
      end

      def open_settings(path)
        save_to_config(settings: path)
        data = YAML.load(File.read(path))
        @window   = data["window"]
        @splits   = data["splits"]
        @timer    = data["timer"]
        @metadata = data["metadata"]
        @colors   = data["colors"]
        @hotkeys  = data["hotkeys"]
      end

      def save_to_config(hash)
        @app_data.merge!(hash)
        Dir.mkdir(APPDIR) unless Dir.exist?(APPDIR)
        File.open(APPFILE, "w") { |f| f.write(YAML.dump(@app_data)) }
      end
    end
  end
end
