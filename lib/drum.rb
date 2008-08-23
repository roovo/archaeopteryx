module Archaeopteryx
  class Drum
    attr_accessor :note, :probabilities, :base_strategy, :next, :number_generator
    
    def initialize(attributes)
      %w{note probabilities base_strategy next number_generator}.each do |attribute|
        eval("@#{attribute} = attributes[:#{attribute}]")
      end
      @strategies = [attributes[:base_strategy]]
      generate_probability_strategy
    end
    
    # TODO: tell don't ask...
    def play?(beat)
      @when[beat]
    end
    
    def generate_probability_strategy
      beats_on_which_to_play = []
      @probabilities.each_with_index do |probability, index|
        beats_on_which_to_play << index if @number_generator[] <= probability
      end
      @strategies << L{ |beat| beats_on_which_to_play.include? beat }
      @when = @next[@strategies]
    end
    alias :mutate :generate_probability_strategy
  end
end
