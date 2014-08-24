module Ld30

  class Game

    INDEFERENCES = ["indef1", "indef2", "indef3", "indef4"]
    INTERCHANGER = ["intrchngr1", "intrchngr2", "intrchngr3", "intrchngr4",
                   "intrchngr5"]
    PANELS_COUNT = 2
    FIELD_SIZE   = 8

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
      fill_up_empty_fields

      # get random id-less field in given panel and place interchanger there
      (0..1).each do |panel_no|
        INTERCHANGER.each do |changer|
          loop do
            row_no    = rand(FIELD_SIZE)
            column_no = rand(FIELD_SIZE)
            if @panels.field(panel_no, row_no, column_no).id.empty?
              @panels.field(panel_no, row_no, column_no).id =
                changer+"p"+(panel_no+1).to_s
              break
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

    # returns true, if exchange happend, else false
    def exchange(field1, field2)
      # Is it next to the current element? <== how figure this out?
      c_position = @panels.position_of field1
      f_position = @panels.position_of field2
      # Must be on the same panel
      # x+1, x-1, y=y
      # y+1, y-1, x=x
      if ((c_position[0] == f_position[0]) and
        (c_position[1] == f_position[1] and
          (c_position[2] == f_position[2]-1 or
            c_position[2] == f_position[2]+1)) or
        (c_position[2] == f_position[2] and
          (c_position[1] == f_position[1]-1 or
            c_position[1] == f_position[1]+1))
      )
        # Find connected fields (= same class) and return a list
        # But use the class of the other field, because of exchange!!!
        neighbor_fields = Array()
        neighbor_fields[0] =
          connected_fields(c_position, f_position, field2.class_name)
        neighbor_fields[1] =
          connected_fields(f_position, c_position, field1.class_name)

        # End here, if none of the arrays has at least 3 entries
        if(neighbor_fields[0].count < 3 and neighbor_fields[1].count < 3)
          return false 
        end

        # Do the exchange
        change_field_contents(f_position, c_position)

        # join the lists, if both have more then 3 entries
        if neighbor_fields[0].count >= 3 and neighbor_fields[1].count >= 3
          neighbor_fields[0] = (neighbor_fields[0] + neighbor_fields[1]).uniq
          neighbor_fields[1] = Array()
        end

        # Plop all fields array, if we have at least 3 entries
        neighbor_fields.each do |fields|
          if fields.count >= 3
            fields.each do |field|
              # polppeldops
              @panels.set_field(field[0], field[1], field[2], "")
            end
            fill_up_fields(fields, c_position[0],
              c_position[1]-f_position[1],  c_position[2]-f_position[2])
          end
        end

        # Exchange content of the interchangers
        INTERCHANGER.each do |changer|
          change_field_contents(
            @panels.position_by_id(changer+"p1"),
            @panels.position_by_id(changer+"p2")
          )
        end

        true
      else
        false
      end
    end

    def connected_fields(position, old_position, value)
      # Strip the "clicked" from the class name
      value = value.chomp("clicked").strip

      found                 = Array()
      found.push position
      frontier              = Array()
      frontier.push(position)
      visited               = {}
      visited[position]     = true

      unless @panels.field(position[0], position[1], position[2]).
          class_name.include? value

        visited[old_position] = true
      end

      while not frontier.empty?
        current = frontier.pop()
        neighbors(current).each do |successor|
          unless visited.key? successor
            visited[successor] = true

            # see if it has the same class
            if @panels.field(successor[0], successor[1], successor[2]).
                class_name.include? value

              # add to found list
              frontier.push successor
              found.push successor
            end
          end
        end
      end

      found
    end

    def neighbors(position)
      fields = []
      # x+1; x-1; y+1; y-1
      unless position[1] == (FIELD_SIZE-1)
        fields.push [position[0], position[1]+1, position[2]]
      end
      unless position[1] == 0
        fields.push [position[0], position[1]-1, position[2]]
      end
      unless position[2] == (FIELD_SIZE-1)
        fields.push [position[0], position[1], position[2]+1]
      end
      unless position[2] == 0
        fields.push [position[0], position[1], position[2]-1]
      end

      fields
    end

    def fill_up_fields(fields, panel_no, x_direction, y_direction)
      # get all x
      #                   x  y
      # up    -> down  :  1  0
      # down  -> up    : -1  0
      # left  -> right :  0  1
      # right -> left  :  0 -1
      rows = Array()
      if y_direction == 0
        position = 2
      else 
        position = 1
      end
      fields.each do |field|
        rows.push field[position]
      end
      rows = rows.uniq

      rows.each do |row|
        # Get all field entries
        entries = Array()
        (0..(FIELD_SIZE-1)).each do |field|
          if y_direction == 0
            entry = @panels.field(panel_no, field, row).class_name
          else
            entry = @panels.field(panel_no, row, field).class_name
          end
          entries.push entry unless entry.empty?
          # then empty field
          if y_direction == 0
            @panels.set_field(panel_no, field, row, "")
          else
            @panels.set_field(panel_no, row, field, "")
          end
        end
        # then refill the row
        if x_direction == 1 or y_direction == 1
          field = FIELD_SIZE-1
          entries.reverse.each do |entry|
            if y_direction == 0
              @panels.set_field(panel_no, field, row, entry)
            else
              @panels.set_field(panel_no, row, field, entry)
            end
            field = field-1
          end
        else
          field = 0
          entries.each do |entry|
            if y_direction == 0
              @panels.set_field(panel_no, field, row, entry)
            else
              @panels.set_field(panel_no, row, field, entry)
            end
            field = field+1
          end
        end
      end
      # Fill up all the empty fields with indeferences
      fill_up_empty_fields
    end


    # fill up empty fields
    def fill_up_empty_fields
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

    def change_field_contents(field1, field2)
      field2_value = @panels.field(field2[0], field2[1], field2[2]).class_name
      @panels.set_field(field2[0], field2[1], field2[2],
        @panels.field(field1[0], field1[1], field1[2]).class_name)
      @panels.set_field(field1[0], field1[1], field1[2], field2_value)
    end

  end

end
