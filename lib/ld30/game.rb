module Ld30

  class Game

    INDEFERENCES = ["indef1", "indef2", "indef3", "indef4"]
    PANELS_COUNT = 2
    FIELD_SIZE  = 8

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
          self.random_empty_field = "person"
        end
      end

      # Fill up all the empty fields with indeferences
      (0..(PANELS_COUNT-1)).each do |panel_no|
        (0..(FIELD_SIZE-1)).each do |row_no|
          (0..(FIELD_SIZE-1)).each do |column_no|
            # if field is empty choose a random indeference and put it in
            if @panels.field(panel_no, row_no, column_no).class_name.empty?
              @panels.set_field(panel_no, row_no, column_no,
                INDEFERENCES[rand(INDEFERENCES.count)])
            end
          end
        end
      end

    end

    def cleanup_level
      # write some code here
    end

    def random_empty_field= value
      # find a random empty field
      loop do
        panel_no  = rand(PANELS_COUNT)
        row_no    = rand(FIELD_SIZE)
        column_no = rand(FIELD_SIZE)
        if @panels.field(panel_no, row_no, column_no).class_name.empty?
          @panels.set_field(panel_no, row_no, column_no, value)
          break
        end
      end
    end

  end

end