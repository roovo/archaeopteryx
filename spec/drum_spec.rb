require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe Archaeopteryx::Drum, "general behaviour" do
  
  before(:each) do
    @note = mock("note")
  end
  
  it "should have the note it was initialized with" do
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => L{ |beat| false },
                                   :probabilities     => [1, 1, 1, 1],
                                   :number_generator  => L{1.0},
                                   :strategy_select   => L{ |strategies| strategies[strategies.size - 1] })
    drum.note.should == @note
  end
  
  it "should call the number generator proc once for each entry in the probability array" do
    @number_generator_proc.should_receive(:[]).exactly(5).times.and_return(1.0)
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => L{ |beat| false },
                                   :probabilities     => [1, 1, 1, 1, 1],
                                   :number_generator  => @number_generator_proc,
                                   :strategy_select   => L{ |strategies| strategies[strategies.size - 1]})
    
  end
end

describe Archaeopteryx::Drum, "forcing the :base_strategy proc to determine which notes to play (by setting :strategy_select to 'L{ |strategies| strategies[0] }')" do
  
  before(:each) do
    @note = mock("note")
  end
  
  it "should call the :base_strategy proc for every note that's played (i.e. it's the :base_strategy proc that determines what is played)" do
    @base_strategy_proc.should_not_receive(:[]).exactly(5).times.and_return(true)
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => @base_strategy_proc,
                                   :probabilities     => [1, 0],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[0] })
    drum.play?(0)
    drum.play?(1)
    drum.play?(2)
    drum.play?(3)
    drum.play?(4)
  end
  

  it "should play every note whatever the probabilities if the :base_strategy proc returns true" do
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => L{ |beat| true },
                                   :probabilities     => [1, 0, 1, 0],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[0] })
    drum.play?(0).should be_true
    drum.play?(1).should be_true
    drum.play?(2).should be_true
    drum.play?(3).should be_true
  end
  
  it "should play a note on a beat that's greater than the size of the probability matrix if the :base_strategy proc returns true" do
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => L{ |beat| true },
                                   :probabilities     => [1, 0, 1, 0],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[0] })
    drum.play?(4).should be_true
    drum.play?(5).should be_true
    drum.play?(6).should be_true
  end
  
  it "should play no notes at all whatever the probabilities if the :base_strategy proc returns false" do
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => L{ |beat| false },
                                   :probabilities     => [1, 0, 1, 0],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[0] })
    drum.play?(0).should be_false
    drum.play?(1).should be_false
    drum.play?(2).should be_false
    drum.play?(3).should be_false
    drum.play?(4).should be_false
  end
  
  it "should NOT play a note on a beat that's greater than the size of the probability matrix if the :base_strategy proc returns false" do
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => L{ |beat| false },
                                   :probabilities     => [1, 0, 1, 0],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[0] })
    drum.play?(4).should be_false
    drum.play?(5).should be_false
    drum.play?(6).should be_false
  end
end

describe Archaeopteryx::Drum, "forcing the probability matrix & number generator to determine which notes to play (by setting :strategy_select to 'L{ |strategies| strategies[1] }')" do
  
  before(:each) do
    @note = mock("note")
  end

  it "should NOT call the :base_strategy proc (i.e. what is played is not influenced by it)" do
    @base_strategy_proc.should_not_receive(:[])
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => @base_strategy_proc,
                                   :probabilities     => [1, 0, 1, 0, 0],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[1] })
    drum.play?(0)
    drum.play?(1)
    drum.play?(2)
    drum.play?(3)
    drum.play?(4)
  end
  
  
  it "should play the notes as defined by the probability matrix & number generator" do
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => nil, # irrelevant here as :strategy_select is forcing use of the probabilities
                                   :probabilities     => [1, 0.4999999999, 0.500000000001, 0, 0.5],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[1] })
    drum.play?(0).should be_true
    drum.play?(1).should be_false
    drum.play?(2).should be_true
    drum.play?(3).should be_false
    drum.play?(4).should be_true
  end
  
  it "should NOT play any notes on beats that are greater than the size of the probability matrix" do
    drum = Archaeopteryx::Drum.new(:note              => @note, 
                                   :base_strategy     => nil, # irrelevant here as :strategy_select is forcing use of the probabilities
                                   :probabilities     => [1, 0.4999999999, 0.500000000001, 0, 0.5],
                                   :number_generator  => L{ 0.5 },
                                   :strategy_select   => L{ |strategies| strategies[1] })
    drum.play?(5).should be_false
    drum.play?(6).should be_false
    drum.play?(7).should be_false
  end
end
