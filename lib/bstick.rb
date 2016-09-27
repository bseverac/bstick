require "bstick/version"
require "net/ping"
require_relative "blinkstick.rb"

module Bstick
  class Server
    def initialize
      file = File.expand_path("../../led.state", __FILE__)
      @file   = File.open(file, "a+")
      @state  = 'off'
      @values = {}
    end

    def stick
      @b ||= BlinkStick.find_all.first
    end

    def black
      @black ||= Color::RGB.from_html("#000000")
    end

    def green
      @green = Color::RGB.new(0x00, 0xFF, 0x00)
    end

    def red
      @red = Color::RGB.new(0xFF, 0x00, 0x00)
    end

    def read_state
      @old_state = @state
      @file.seek(0)
      @state = @file.readline.strip rescue 'off'
    end

    def set_colors(color_1, color_2)
      stick.set_color(0, 0, color_1)
      stick.set_color(0, 1, color_2)
    end

    def off_state
      return if @old_state == 'off'
      puts 'off'
      set_colors(black, black)
    end

    def on_state
      return if @old_state == 'on'
      puts 'on'
      set_colors(green, green)
    end

    def blink_state
      if @old_state != 'blink'
        puts 'blink'
        @values = { green: 0, direction: 20 }
      end
      color_1 = Color::RGB.new(0xFF - @values[:green], @values[:green], 0x00)
      color_2 = Color::RGB.new(@values[:green], 0xFF - @values[:green], 0x00)
      @values[:green] += @values[:direction]
      if(@values[:green] < 0 || @values[:green] > 0xFF)
        @values[:direction] *= -1
      end
      set_colors(color_1, color_2)
    end

    def ping_state
      @wait ||= 16 * 33
      @wait += 1
      return if @wait < 15 * 33
      puts 'ping'
      @wait = 0
      @ping ||= ''
      url = @state.split(' ')[1] || "http://www.undefine.io"
      ping = Net::Ping::HTTP.new(url)
      if ping.ping?
        return if @ping == 'true'
        set_colors(green, green)
      else
        return if @ping == 'false'
        set_colors(red, red)
      end
      @ping = ping.ping? ? 'true' : 'false'
    end

    def handle_state
      case @state.split(' ').first
      when 'off'   then off_state
      when 'on'    then on_state
      when 'blink' then blink_state
      when 'ping'  then ping_state
      end
    end

    def run
      loop do
        read_state
        handle_state
        sleep 1/33.0
      end
    end
  end
end
