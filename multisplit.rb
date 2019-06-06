require "yaml"
require "models/data"
require "models/route"
require "models/timer"
require "models/basic_splits"
require "models/splits"
require "ui/window"
require "ui/split_table"
require "ui/times"
require "ui/metadata"

module Multisplit
  module_function
  Data.init_app_data

  def open_app
    Shoes.app title: "Multisplit",
      height: Data.window["height"], width: Data.window["width"] do
      extend Window
      extend SplitTable
      extend Times
      extend Metadata

      background Data.colors["background"]
      style Shoes::Title, stroke: Data.colors["normal-text"]
      style Shoes::Para, stroke: Data.colors["normal-text"], weight: "bold"

      @body = stack margin: 15

      path = Data.app_data[:splits]
      begin
        return if path.nil?
        open_splits(path)
      rescue
        open_basic
      end
      animate(60) { display_timer }

      keypress do |key|
        case key.to_s
        when "control_c" then open_basic
        when "control_s" then save_splits(@splits.path)
        when "control_S" then save_splits(ask_open_file)
        when "control_o" then open_splits(ask_open_file)
        when "control_e" then open_settings(ask_open_file)
        when "control_i" then alert(split_info, title: "Information")
        when Data.hotkeys["split"] then @splits.split
        when Data.hotkeys["reset"] then @splits.reset
        when Data.hotkeys["pause"] then @splits.pause
        when Data.hotkeys["next-split"]  then @splits.next
        when Data.hotkeys["prev-split"]  then @splits.prev
        when Data.hotkeys["toggle-best"] then @splits.toggle_best
        when /[123456789]/ then @splits.change_route(key.to_i)
        end
        reload_splits unless @splits.basic?
      end
    end
  end
end

Multisplit.open_app
