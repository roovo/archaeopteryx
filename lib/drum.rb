module Archaeopteryx

  # = Generates a drum pattern
  # 
  # This is similar in principle to a single patch in a drum step sequencer but a whole
  # lot more flexible.  Rather than just having the choice of whether a drum sample 
  # is triggered on a given step or not, you have a lot more freedom.  You can configure 
  # the drum to generate:
  # 
  # * a fixed drum pattern (as per a traditional drum sequencer)
  # * a changing pattern based on a probability array
  # * a changing pattern controlled by calling a lambda (an external function)
  # * a combination of these two methods
  # 
  # == Generating a fixed pattern
  # If you set up some Drums as follows:
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
  # This will save two Drums each of which can generate a 16 step sequence.  The drums will trigger 
  # on the steps where there is a 1.0 in the array and not trigger where there is a 0.0.  
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
  # == Generating a changing pattern based on a probability array
  # Set up your Drums as follows:
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
  # Here, some of the values in the probability arrays are between 0.0 and 1.0, and the number_generator 
  # lambda has been set to return a random number.  A drum will always trigger an a step where there is a 1.0 
  # and never trigger where there is a 0.0.  For the in-between values, the closer it is to 1 the more 
  # likely it is to trigger.
  # 
  # The way this works is the :number_generator lambda is called for each step in the array and if 
  # the number in the array is greater than or equal to the number it returns then the drum will be
  # triggered for that step.
  # 
  # The result is a drum pattern that is based on the array but will change each time a new pattern
  # is generated - cool or what.
  # 
  # == Generating a changing pattern controlled by calling a lambda (an external function)
  # Set up your Drums as follows:
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
  # Here, the strategy_select lambda has been changed to use the external strategy and the external strategy
  # has been set to randomly return either true or false.  This is not going to sound good but 
  # you get the idea.  You should use something that returns true or false based on a more rhythmic quality 
  # than a random generator.
  # 
  # Note that you must still provide a probability array even if you are only using the external 
  # strategy as the drum won't know until run-time which strategy it is supposed to be using.  
  # It just won't matter what you put in it.
  # 
  # == Generating a changing pattern using a combination of these two methods
  # Set up your Drums as follows:
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
  # Here
  # * the strategy_select lambda randomly chooses either the external strategy or the probability array
  # * the external strategy has been set to never trigger a drum
  # * the number_generator will produce a random number for use in the probability array.
  # 
  # The result of this is that the pattern will be generated based  on the probability array as above but 
  # this time the drum won't always be triggered according to the probability array (e.g. it will not always
  # trigger on steps where there is a 1.0 in the array).
  # 
  # This happens as the strategy_select lambda is called for each step.  So if it returns the external 
  # strategy the drum will not be triggered whatever is contained in the prabability array.
  # 
  class Drum
    attr_accessor :note, :probabilities, :external_strategy, :strategy_select, :number_generator
    
    # Creates a new drum
    # 
    # === Parameters
    # attributes:: An attributes hash (see below)
    #
    # === Attributes
    # :note<Symbol>:: The note for this drum
    # :external_strategy<lambda>:: a lambda which can be used for triggering drums (see below)
    # :probabilities<Array>:: An array of probabilities with an entry for each step (see above)
    # :number_generator<lambda>:: An lambda used in the probability array strategy (see below)
    # :strategy_select<lambda>:: A lambda used to choose the strategy which should be used to determine if a drum should be triggered
    #
    # ==== :external_strategy
    # This lambda is called for each step where the external strategy is selected (see :strategy_select).
    # The lambda will be passed the step number and should return either true or false to
    # instruct the drum to trigger on the step or not.
    # 
    # Examples:
    #   # never trigger the drum on the step
    #   :external_strategy => L{ |step| false }
    # 
    #   # always trigger the drum on the step
    #   :external_strategy => L{ |step| true }
    # 
    #   # randomly trigger the drum on the step
    #   :external_strategy => L{ |step| [false, true][rand(2)] }
    # 
    #   # trigger on every 4th step
    #   :external_strategy => L{ |step| step.modulo(4).zero? }
    # 
    # ==== :number_generator
    # This lambda is called for each entry in the probability array.  The lambda takes
    # no parameters and should return a number between 0.0 and 1.0.  See above for more information
    # on how this is used.
    #
    # ==== :strategy_select
    # This lambda is called each time the play? method is called. The lambda will be passed 
    # an array containing the two strategies available for generating the pattern; the external 
    # strategy at index 0 and the probability array strategy at index 1.  It should return 
    # the strategy to be used on the step.
    # 
    # Examples:
    #   # use the external strategy
    #   :strategy_select => L{ |strategies| strategies[0] }
    # 
    #   # use the probability array strategy
    #   :strategy_select => L{ |strategies| strategies[1] }
    # 
    #   # randomly choose one of the two strategies
    #   :strategy_select => L{ |strategies| strategies[rand(strategies.size)] }
    # 
    def initialize(attributes)
      %w{note external_strategy probabilities number_generator strategy_select}.each do |attribute|
        eval("@#{attribute} = attributes[:#{attribute}]")
      end
      @strategies = [attributes[:external_strategy]]
      generate_probability_strategy
    end
    
    # returns true if the drum should trigger on the step
    #--
    # TODO: tell don't ask...
    #++
    def play?(step)
      @strategy_selector[step]
    end
    
    # This should probably be a private method, but I haven't sussed out what
    # the mutate method is for yet...
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
