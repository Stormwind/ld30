module Ld30


  #
  # Wrapper for JS interaction
  #
  #
  class Panels

    def initialize
      @panels = Element.find("#panels")
    end

    def field(position)
      Element.find("table:eq(#{position[0]})").children().
        children("tr:eq(#{position[1]})").children("td:eq(#{position[2]})")
    end

    def set_field(position, value)
      field(position).class_name = value
    end

    def position_of(field)
      # use constants instead of numbers
      [1-field.parent.parent.parent.find("~ table").count,
        7-field.parent.find("~ tr").count,
        7-field.find("~ td").count]
    end

    def position_by_id(id)
      position_of Element.find("#"+id.to_s)
    end

    def field_by_id(id)
      Element.find("#"+id.to_s)
    end

    def somebody_out_there?
      if Element.find(".lisa, .ralf, .otto, .bernadette, .fridolin, .michael,"+
        " .susanne, .karl, .josephine, .mia").empty?
        return false
      end

      true
    end

    def empty_fields pattern
      Element.find(pattern).class_name = ""
    end

  end
end