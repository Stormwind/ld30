module Ld30

  class Score

    # Defines the cost for a single switch
    COST        = 250
    PERSON      = 1000
    BASIC_SCORE = 10

    def initialize
      @level = Element.find("#level .value")

      @level_people = Element.find("#people .value")
      @level_people.text = 0
      @overall_people = Element.find("#total-people .value")
      @overall_people.text = 0

      @level_score = Element.find("#score .value")
      @level_score.text = 0
      @overall_score = Element.find("#total-score .value")
      @overall_score.text = 0
    end

    def sub_cost
      sub_score COST
    end

    def add_fields count
      (1..count).each do |number|
        add_score (number*BASIC_SCORE)
      end
    end

    def add_person
      add_score PERSON
      @level_people.text = @level_people.text.to_i + 1
      @overall_people.text = @overall_people.text.to_i + 1
    end

    def next_level
      @level.text = @level.text.to_i + 1
      @level_score.text = 0
      @level_people.text = 0
    end

    def add_score value
      @level_score.text = @level_score.text.to_i + value
      @overall_score.text.to_i = @overall_score.text.to_i + value
    end

    def sub_score value
      @level_score.text.to_i = @level_score.text.to_i - value
      @overall_score.text.to_i = @overall_score.to_i - value
    end

  end

end