require 'rspec'

module Spec
  module SubRip
    class SubRipSpec < SubRip
      class << self
        attr_accessor :examples_ran
      end
      
      after(:all) do
        self.class.examples_ran = true
      end
    
      describe ExampleGroupSubclass do
        it "should run" do
          SubRipSpec.examples_ran.should be_true
        end
      end
    end
  end
end

describe SubRip do
  orig_file = './fixture/smallville-subtitle-original.srt'
  dest_file = '/tmp/smallville-subtitle-modified.srt'
  
  it "should load" do
    SubRip.new(orig_file)
  end
  
end

describe do
  Kernel.exec("../shift_sub_rip --operation add --time 02,110 #{orig_file} #{dest_file}")
  
  original = SubRip.new(orig_file)
  modified = SubRip.new(dest_file)
  
  it "should be shifted by 2,110 sec" do
    original.each do |moment|
      modified_moment = modified[moment.id]
      modified_moment.time.should be_equal moment.time + 2,110
    end
  end
end
