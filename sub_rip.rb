require 'time'

class SubRip < Array
  def initialize filename
    super()
    @filename = filename
    load filename
  end

  def to_s
    output = ''
    self.each do |i|
      output << "#{i.id}\n"
      output << "#{i.show_at} --> #{i.hidden_at}\n"
      output << "#{i.legend}\n\n"
    end
    output
  end

  def save dest_file=@filename
    File.open(dest_file,'w') do |f|
      f.print self.to_s
    end
  end

  class Subtitle
    attr_reader :id
    attr_accessor :show_at, :hidden_at, :legend

    def initialize id, show_at, hidden_at, legend_msg
      @id, @show_at, @hidden_at, @legend = id, show_at, hidden_at, legend_msg
    end

    def to_s
      "Subtitle(#{@id})[show_at: '#{@show_at}', hidden_at: '#{@hidden_at}', legend: '#{@legend}',]"
    end
  end

  class MomentTime
    attr_reader :time_ms

    def initialize(time=Time.now.strftime('%H:%M:%S,%L'))
      @time_ms = time.is_a?(Numeric) ? time.to_i : to_msec(time)
    end

    def + time_sec
      @time_ms += (time_sec.respond_to?(:time_ms) ? time_sec.time_ms : time_sec * 1_000)
      self
    end

    def - time_sec
      @time_ms -= (time_sec.respond_to?(:time_ms) ? time_sec.time_ms : time_sec * 1_000)
      self
    end

    def to_s
      to_mtime(@time_ms)
    end

    private
    def to_msec time
      return time if time.is_a? Numeric

      msec_multiplier = [1, 1_000, 60_000, 3_600_000]
      time.split(/[:\,]/).map{|t| t.to_i * msec_multiplier.pop}.inject(:+)
    end

    def to_mtime ms_time
      multipliers = [3_600_000, 60_000, 1_000, 1]
      conv_time = []

      (0..3).each do |idx; conv_counter|
        conv_counter = -1
        val = conv_time.inject(ms_time){|counter,value| counter - value * multipliers[conv_counter += 1]}
        val ||= 0

        conv_time << ((val)/multipliers[idx]).to_i
      end

      "%02d:%02d:%02d,%03d" % conv_time
    end
  end

  private
  def load filename
    File.open(filename, 'r') do |f|
      contents = f.read.split(/\n\n/)
      contents.each do |i|
        by_line = i.split(/\n/)
        id = by_line.shift.to_i
        time = by_line.shift.split(' --> ').map{|t| MomentTime.new(t)}
        legend = by_line.join("\n")
        self[id] = Subtitle.new(id,time[0],time[1],legend)
      end
    end
  end
end

