module Ld30

  class Game

    def initialize
      @panels = Array.new(2) { Array.new(8) { Array.new(8)}}

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
      gnrtr = Random.new
      # find a random empty field
      field = nil
      loop do
        panel_no = gnrtr.rand(2)
        line_no  = gnrtr.rand(8)
        field_no = gnrtr.rand(8)
        if @panels[panel_no][line_no][field_no].nil?
          @panels[panel_no][line_no][field_no] = value
          # put the person on the real gamefield
          break
        end
      end
    end

  end

end