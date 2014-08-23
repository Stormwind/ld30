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
      field(panel, row, column).add_class "person"
    end


  end

end