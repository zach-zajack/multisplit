require "yaml"
require "models/data"
require "models/route"
require "models/timer"
require "models/basic_splits"
require "models/splits"
require "ui/window"
require "ui/split_table"

module Multisplit
  Data.init_app_data
  Data.open_settings("default.yaml")

  Shoes.app title: "Multisplit",
    height: Data.window["height"], width: Data.window["width"] do
    extend Window
    extend SplitTable

    style Shoes::Title, stroke: Data.colors["normal-text"]
    style Shoes::Para,  stroke: Data.colors["normal-text"], \
      weight: "bold", wrap: "trim"

    background Data.colors["background"]

    @body  = stack
    @timer = title "", margin_right: 30, align: "right"

    path = Data.app_data[:splits]
    path.nil? ? open_basic : open_splits(path)

    animate(60) { @timer.replace(@splits.timer.display) }

    keypress do |key|
      case key.to_s
      when "control_c" then open_basic
      when "control_s" then save_splits(@path)
      when "control_S" then save_splits(ask_open_file)
      when "control_o" then open_splits(ask_open_file)
      when "control_e" then open_settings(ask_open_file)
      when "control_i" then alert(split_info, title: "Information")
      when Data.hotkeys["split"] then @splits.split
      when Data.hotkeys["reset"] then @splits.reset
      when Data.hotkeys["pause"] then @splits.toggle_pause
      when Data.hotkeys["next"]  then @splits.next
      when Data.hotkeys["prev"]  then @splits.prev
      when /[123456789]/ then @splits.change_route(key.to_i)
      end
      reload_splits
    end
  end
end
