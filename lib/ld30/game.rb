module Ld30

  class Game

    INDEFERENCES = ["indef1", "indef2", "indef3", "indef4"]
    INTERCHANGER = ["intrchngr1", "intrchngr2", "intrchngr3", "intrchngr4",
                   "intrchngr5"]
    PANELS_COUNT = 2
    FIELD_SIZE   = 8
    PERSONS      = ["lisa", "ralf", "otto", "bernadette", "fridolin",
                   "michael", "susanne", "karl", "josephine", "mia"]
    LEVEL_MAX    = 10

    def initialize
      @panels = Panels.new

      # start a new game
      # current level is 1
      @current_level = 0
      start_level

    end

    def start_level
      number = @current_level+1
      cleanup_level unless number == 1

      # Make a local clone of the persons list
      persons_clone = PERSONS.shuffle
      # Number of people in the level is equal to the level number
      number.downto(1).each do
        person = persons_clone.pop
        (1..3).each do
          # spread person over empty fields
          self.random_empty_field = person
        end
      end

      # Fill up all the empty fields with indeferences
      fill_up_empty_fields

      # get random id-less field in given panel and place interchanger there
      (0..1).each do |panel_no|
        INTERCHANGER.each do |changer|
          loop do
            position = [panel_no, rand(FIELD_SIZE), rand(FIELD_SIZE)]
            if @panels.field(position).id.empty?
              @panels.field(position).id = changer+"p"+(panel_no+1).to_s
              break
            end
          end
        end
      end

      @current_level = number
    end

    def cleanup_level
      # remove all interchanger
      (0..1).each do |panel_no|
        INTERCHANGER.each do |changer|
          @panels.field_by_id(changer+"p"+(panel_no+1).to_s).id = ""
        end
      end

      # remove all indeferences
      @panels.empty_fields "."+INDEFERENCES.join(", .")
    end

    def random_empty_field= value
      # find a random empty field
      loop do
        position = [rand(PANELS_COUNT), rand(FIELD_SIZE), rand(FIELD_SIZE)]
        if @panels.field(position).class_name.empty?
          @panels.set_field(position, value)
          break
        end
      end
    end

    # returns true, if exchange happend, else false
    def exchange(field1, field2)
      # Is it next to the current element? <== how figure this out?
      pos_f1 = @panels.position_of field1
      pos_f2 = @panels.position_of field2
      # Must be on the same panel
      # x+1, x-1, y=y
      # y+1, y-1, x=x
      if ((pos_f1[0] == pos_f2[0]) and
        (pos_f1[1] == pos_f2[1] and
          (pos_f1[2] == pos_f2[2]-1 or pos_f1[2] == pos_f2[2]+1)) or
        (pos_f1[2] == pos_f2[2] and
          (pos_f1[1] == pos_f2[1]-1 or pos_f1[1] == pos_f2[1]+1))
      )
        # Find connected fields (= same class) and return a list
        # But use the class of the other field, because of exchange!!!
        neighbor_fields = Array()
        neighbor_fields[0] =
          connected_fields(pos_f1, pos_f2, field2.class_name)
        neighbor_fields[1] =
          connected_fields(pos_f2, pos_f1, field1.class_name)

        # End here, if none of the arrays has at least 3 entries
        if(neighbor_fields[0].count < 3 and neighbor_fields[1].count < 3)
          return false 
        end

        # Do the exchange
        change_field_contents(pos_f2, pos_f1)

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
              @panels.set_field(field, "")
            end
            fill_up_fields(fields, pos_f1[0],
              pos_f1[1]-pos_f2[1],  pos_f1[2]-pos_f2[2])
          end
        end

        # End of level?
        # If there is no more person on the gamefield. The level ends.
        unless @panels.somebody_out_there?
          start_level
          return true
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

      unless @panels.field(position).class_name.include? value
        visited[old_position] = true
      end

      while not frontier.empty?
        current = frontier.pop()
        neighbors(current).each do |successor|
          unless visited.key? successor
            visited[successor] = true

            # see if it has the same class
            if @panels.field(successor).class_name.include? value
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
            entry = @panels.field([panel_no, field, row]).class_name
          else
            entry = @panels.field([panel_no, row, field]).class_name
          end
          entries.push entry unless entry.empty?
          # then empty field
          if y_direction == 0
            @panels.set_field([panel_no, field, row], "")
          else
            @panels.set_field([panel_no, row, field], "")
          end
        end
        # then refill the row
        if x_direction == 1 or y_direction == 1
          field = FIELD_SIZE-1
          entries.reverse.each do |entry|
            if y_direction == 0
              @panels.set_field([panel_no, field, row], entry)
            else
              @panels.set_field([panel_no, row, field], entry)
            end
            field = field-1
          end
        else
          field = 0
          entries.each do |entry|
            if y_direction == 0
              @panels.set_field([panel_no, field, row], entry)
            else
              @panels.set_field([panel_no, row, field], entry)
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
            if @panels.field([panel_no, row_no, column_no]).class_name.empty?
              @panels.set_field([panel_no, row_no, column_no],
                INDEFERENCES[rand(INDEFERENCES.count)])
            end
          end
        end
      end
    end

    def change_field_contents(field1, field2)
      field2_value = @panels.field(field2).class_name
      @panels.set_field(field2, @panels.field(field1).class_name)
      @panels.set_field(field1, field2_value)
    end

  end

end
