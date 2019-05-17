require "yaml"
require "lib/data"
require "lib/route"
require "lib/basic_splits"
require "lib/splits"
require "lib/timer"
require "lib/window"

module Multisplit
  Data.reload

  Shoes.app title: "Multisplit",
    height: Data.window["height"], width: Data.window["width"] do
    extend Window

    style Shoes::Para,  stroke: Data.colors["normal-text"]
    style Shoes::Title, stroke: Data.colors["normal-text"]

    background Data.colors["background"]

    @body  = stack
    @timer = title "", margin_right: 30, align: "right"

    path = Data.window["open-by-default"]
    path.nil? ? open_basic : open_splits(path)

    animate(60) { @timer.replace(@splits.timer.display) }

    keypress do |key|
      case key.to_s
      when "control_c" then open_basic
      when "control_s" then save_splits(@path)
      when "control_S" then save_splits(ask_open_file)
      when "control_o" then open_splits(ask_open_file)
      when Data.hotkeys["split"] then @splits.split
      when Data.hotkeys["reset"] then @splits.reset
      when Data.hotkeys["pause"] then @splits.pause
      when Data.hotkeys["next"]  then @splits.next
      when Data.hotkeys["prev"]  then @splits.prev
      when /[123456789]/ then @splits.change_route(key.to_i)
      end
      reload_splits
    end
  end
end
