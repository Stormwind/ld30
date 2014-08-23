module Ld30

  class Game

    def initialize
      @panels = Panels.new

      # start a new game
      # current level is 1
      start_level 1

    end

    def start_level number
      cleanup_level unless number == 1

      # Number of people in the level is equal to the level number
      number.downto(1).each do |person|
        (1..3).each do
          # spread person over empty fields
          self.random_empty_field = person
        end
      end

    end

    def cleanup_level
      # write some code here
    end

    def random_empty_field= value
      # find a random empty field
      loop do
        panel_no = rand(2)
        line_no  = rand(8)
        field_no = rand(8)
        if @panels.field(panel_no, line_no, field_no).class_name.empty?
          @panels.set_field(panel_no,line_no, field_no, value)
          break
        end
      end
    end

  end

end