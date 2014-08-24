module Ld30


  #
  # Wrapper for JS interaction
  #
  #
  class Panels

    def initialize
      @panels = Element.find("#panels")
    end

    def field(panel, row, column)
      Element.find("table:eq(#{panel})").children().
        children("tr:eq(#{row})").children("td:eq(#{column})")
    end

    def set_field(panel, row, column, value)
      field(panel, row, column).class_name = value
    end

    def position_of(field)
      # use constants instead of numbers
      [1-field.parent.parent.parent.find("~ table").count,
        7-field.parent.find("~ tr").count,
        7-field.find("~ td").count]
      end

  end

end