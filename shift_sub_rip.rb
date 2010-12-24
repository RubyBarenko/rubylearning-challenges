require 'sub_rip'

class ShiftSubRipSpec

  def initialize
    @map = {
      :operation => nil,
      :time => 0,
      :input_file => nil,
      :output_file => nil
    }

    analize_input
    start_process
  end

  def analize_input
    args = ARGV.clone
    @map[:output_file] = args.pop
    @map[:input_file] = args.pop

    if not args.empty? and args.size.even? then
      2.times do
        if args[-2].start_with? '--' then
          @map[args[-2].sub(/^--/,'').to_sym] = args.pop
          args.pop
        end
      end
    else
      error_msg
    end

    error_msg if @map[:input_file].nil? or @map[:input_file].nil?

    if [:add,:sub].member?(@map[:operation].to_sym) then
      @map[:operation] = @map[:operation].to_sym == :add ? :+ : :-
    else
      error_msg
    end
  end

  def error_msg
    puts 'The input_file and output_file are mandatory!'
    puts 'Try again...'
    puts 'Sample: shift_subtitle --operation add --time 02,110 input_file output_file'
    exit 1
  end

  def start_process
    sub_rip = SubRip.new(@map[:input_file])
    sub_rip.each{|s| s.show_at.send(@map[:operation], @map[:time].to_f) }
    puts sub_rip.to_s
    sub_rip.save @map[:output_file]
  end
end

ShiftSubRipSpec.new()



__END__
s = SubRip.new('./spec/fixtures/smallville-subtitle-original.srt')
s.each{|a| puts "Orig: #{a.show_at} to: #{a.show_at + 3.3}"}



shift_subtitle --operation add --time 02,110 input_file output_file

This means “--operation” can accept either ‘add’ or ‘sub’ to add or subtract times.
The “--time” will accept the amount of time to shift in the format 11,222 where “11″ is the amount of seconds and “222″ the amount of milliseconds.
