module Archaeopteryx
  class Drum
    attr_accessor :note, :probabilities, :external_strategy, :strategy_select, :number_generator
    
    def initialize(attributes)
      %w{note probabilities base_strategy strategy_select number_generator}.each do |attribute|
        eval("@#{attribute} = attributes[:#{attribute}]")
      end
      @strategies = [attributes[:external_strategy]]
      generate_probability_strategy
    end
    
    # TODO: tell don't ask...
    def play?(beat)
      @strategy_selector[beat]
    end
    
    def generate_probability_strategy
      beats_on_which_to_play = []
      @probabilities.each_with_index do |probability, index|
        beats_on_which_to_play << index if @number_generator[] <= probability
      end
      @strategies << L{ |beat| beats_on_which_to_play.include? beat }
      @strategy_selector = @strategy_select[@strategies]
    end
    alias :mutate :generate_probability_strategy
  end
end
