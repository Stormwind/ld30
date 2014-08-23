#base_path = File.expand_path('../../', __FILE__)
#$LOAD_PATH << File.expand_path('lib', base_path)

require "opal"
require "opal-jquery"

require 'ld30/game'
require 'ld30/panels'

game = Ld30::Game.new

puts game.inspect

# Events

Element.find('#panels').on(:click, 'td') do |event|
  event.current_target.add_class "clicked"
end