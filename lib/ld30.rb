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
  field = event.current_target
  event.stop_propagation
  # Is already another element clicked?
  clicked = Element.find('.clicked')
  success = false

  unless clicked.empty?
    # Trigger the exchange of the objects
    success = game.exchange(field, clicked)

    # Remove "clicked"-class from the fields
    clicked.remove_class "clicked"
  end

  # Mark current field as "clicked"
  field.add_class "clicked" unless success == true
end
