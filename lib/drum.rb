module Archaeopteryx

  # = Generates a drum pattern
  # 
  # This is similar in principle to a single patch in a drum step sequencer but a whole
  # lot more flexible.  Rather than just having the choice of whether a drum sample 
  # is triggered on a given step, you have a lot more freedom.  You can configure 
  # the drum to generate:
  # 
  #  * a fixed drum pattern (as per a traditional drum sequencer)
  #  * a changing pattern based on a probability matrix
  #  * a changing pattern controlled by calling a lambda (an external function)
  #  * a combination of these two methods
  # 
  # === Generating a fixed pattern
  # You need to set up your Drum as follows:
  # 
  #   probabilities[36] = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
  #   probabilities[37] = [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  # 
  #   def note(midi_note_number)
  #     Note.create(:channel  => 2,
  #                 :number   => midi_note_number,
  #                 :duration => 0.25,
  #                 :velocity => 100 + rand(27))
  #   end
  # 
  #   drums = []
  #   (36..37).each do |midi_note_number|
  #     drums << Drum.new(:note               => note(midi_note_number),
  #                       :external_strategy  => nil,
  #                       :number_generator   => L{ 1.0 },
  #                       :strategy_select    => L{ |strategies| strategies[1] },
  #                       :probabilities      => probabilities[midi_note_number])
  #   end
  # 
  # This will save two Drums each which will generate a 16 step sequence.  The drums will trigger 
  # on the steps where there is a 1.0 in the matrix and not trigger where there is a 0.0.  
  # Both drums are on midi channel 2, one on number 36 and one on 37.  
  # 
  # To get the notes which should be triggered from the drum pattern, you should do something along 
  # the lines of:
  # 
  #   drum_notes = []
  # 
  #   (1..16).each do |step|
  #     drums.each do |drum|
  #       drum_notes << drum.note if drum.play? step
  #     end
  #   end
  # 
  # 
  # 
  # === Generating a changing pattern based on a probability matrix
  # Set up your Drum as follows:
  # 
  #   probabilities[36] = [1.0, 0.0, 0.5, 0.25, 0.0, 0.6, 0.0, 0.9, 0.9, 0.0, 1.0, 0.0, 0.5, 0.0, 0.3, 0.0]
  #   probabilities[37] = [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.0, 1.0, 0.0, 0.0, 0.0]
  # 
  #   def note(midi_note_number)
  #     Note.create(:channel  => 2,
  #                 :number   => midi_note_number,
  #                 :duration => 0.25,
  #                 :velocity => 100 + rand(27))
  #   end
  # 
  #   drums = []
  #   (36..37).each do |midi_note_number|
  #     drums << Drum.new(:note               => note(midi_note_number),
  #                       :external_strategy  => nil,
  #                       :number_generator   => L{ rand } ,
  #                       :strategy_select    => L{ |strategies| strategies[1] },
  #                       :probabilities      => probabilities[midi_note_number])
  #   end
  # 
  # Here, some of the values in the probability matrix are between 0.0 and 1.0, and :number_generator 
  # has been set to return a random number.  A drum will always trigger an a step where there is a 1.0 
  # and never trigger where there is a 0.0.  For the in-between values, the closer it is to 1 the more 
  # likely it is to trigger.
  # 
  # The way this works is number_generator is called for each step and if the number in the matrix 
  # is greater than or equal to the number it returns then the drum will be triggered for that step.
  # 
  # The result is a drum pattern that is based on the matrix but will change each time a new pattern
  # is generated - cool or what.
  # 
  # === Generating a changing pattern controlled by calling a lambda (an external function)
  # Set up your Drum as follows:
  # 
  #   probabilities[36] = [1.0]
  #   probabilities[37] = [0.0]
  # 
  #   def note(midi_note_number)
  #     Note.create(:channel  => 2,
  #                 :number   => midi_note_number,
  #                 :duration => 0.25,
  #                 :velocity => 100 + rand(27))
  #   end
  # 
  #   drums = []
  #   (36..37).each do |midi_note_number|
  #     drums << Drum.new(:note               => note(midi_note_number),
  #                       :external_strategy  => L{ |step| [false, true][rand(2)] },
  #                       :number_generator   => L{ 1.0 },
  #                       :strategy_select    => L{ |strategies| strategies[0] },
  #                       :probabilities      => probabilities[midi_note_number])
  #   end
  # 
  # Here, the strategy_select has been changed to use the external strategy and the external strategy
  # has been set to randomly return either true or false.  This is highly likely to sound terrible but 
  # you get the idea.  You could use something return true or false based a a more rhythmic quality 
  # than a random generator.
  # 
  # Note that you must still provide a probability matrix even if you are only using the external 
  # strategy as the drum won't know until run-time which strategy it is supposed to be using.  
  # It just won't matter what you put in it.
  # 
  # === Generating a changing pattern using a combination of these two methods
  # Set up your Drum as follows:
  # 
  #   probabilities[36] = [1.0, 0.0, 0.5, 0.25, 0.0, 0.6, 0.0, 0.9, 0.9, 0.0, 1.0, 0.0, 0.5, 0.0, 0.3, 0.0]
  #   probabilities[37] = [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.0, 1.0, 0.0, 0.0, 0.0]
  # 
  #   def note(midi_note_number)
  #     Note.create(:channel  => 2,
  #                 :number   => midi_note_number,
  #                 :duration => 0.25,
  #                 :velocity => 100 + rand(27))
  #   end
  # 
  #   drums = []
  #   (36..37).each do |midi_note_number|
  #     drums << Drum.new(:note               => note(midi_note_number),
  #                       :external_strategy  => L{ |step| false },
  #                       :number_generator   => L{ rand },
  #                       :strategy_select    => L{ |strategies| strategies[rand(strategies.size)] },
  #                       :probabilities      => probabilities[midi_note_number])
  #   end
  # 
  # Here the strategy select is configured to randomly choose either the external strategy or the
  # probability matrix, the external strategy has been set to never trigger a drum, and the 
  # number_generator will produce a random number for use in the probability matrix.  The result 
  # of this is that the pattern will be generated based  on the probability matrix as above but 
  # this time the drum won't always be triggered on steps where  there is a 1.0 in the matrix.
  # 
  # This happens as the :strategy_select lambda is called for each step.  So if it returns the external 
  # strategy on a step where there is a 1.0 in the matrix it will ignore the matrix and follow the
  # external strategy (which is to not trigger the drum).
  class Drum
    attr_accessor :note, :probabilities, :external_strategy, :strategy_select, :number_generator
    
    def initialize(attributes)
      %w{note external_strategy probabilities number_generator strategy_select}.each do |attribute|
        eval("@#{attribute} = attributes[:#{attribute}]")
      end
      @strategies = [attributes[:external_strategy]]
      generate_probability_strategy
    end
    
    # TODO: tell don't ask...
    def play?(step)
      @strategy_selector[step]
    end
    
    def generate_probability_strategy
      steps_on_which_to_play = []
      @probabilities.each_with_index do |probability, index|
        steps_on_which_to_play << index if @number_generator[] <= probability
      end
      @strategies << L{ |step| steps_on_which_to_play.include? step }
      @strategy_selector = @strategy_select[@strategies]
    end
    alias :mutate :generate_probability_strategy
  end
end
