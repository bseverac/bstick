require "bstick/version"
require "net/ping"
require "logger"
require_relative "blinkstick.rb"

module Bstick
  class Server
    def initialize
      init
    end

    def init
      system 'sudo mkdir -p /var/bstick'
      system 'sudo chmod 777 /var/bstick'
      system 'sudo touch /var/bstick/led.state'
      system 'sudo chmod 777 /var/bstick/led.state'
      @logger = ::Logger.new('/var/bstick/bstick.log', 1, 1024000)
      @state  = ''
      @values = nil
      @b      = nil
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
      file    = File.expand_path("/var/bstick/led.state", __FILE__)
      @file   = File.open(file, "a+")
      File.chmod(0777, file)
      @file.seek(0)
      @state = @file.readline.strip rescue 'off'
      @file.close
    end

    def set_colors(color_1, color_2)
      if stick
        if (color_1 != @color_1 || color_2 != @color_2)
          @logger.info @state
          stick.set_color(0, 0, color_1)
          stick.set_color(0, 1, color_2)
          @color_1 = color_1
          @color_2 = color_2
        end
      else
        @logger.error 'no stick found'
        sleep 10
        init
      end
    end

    def off_state
      set_colors(black, black)
    end

    def on_state
      set_colors(green, green)
    end

    def blink_state
      @values = { green: 0, direction: 20 } if !@values
      color_1 = Color::RGB.new(0xFF - @values[:green], @values[:green], 0x00)
      color_2 = Color::RGB.new(@values[:green], 0xFF - @values[:green], 0x00)
      @values[:green] += @values[:direction]
      if(@values[:green] < 0 || @values[:green] > 0xFF)
        @values[:direction] *= -1
      end
      set_colors(color_1, color_2)
    end

    def ping_state
      @wait += 1
      return if @wait < 15 * 33
      @wait = 0
      url = @state.split(' ')[1] || "http://www.undefine.io"
      ping = Net::Ping::HTTP.new(url)
      @logger.info "ping #{url} #{ping.ping?}"
      if result = ping.ping?
        set_colors(green, green)
      else
        set_colors(red, red)
      end
    end

    def random_state
      @wait += 1
      return if @wait < 0.5 * 33
      @wait = 0
      color_1 = Color::RGB.new(rand(0..0xFF), rand(0..0xFF), rand(0..0xFF))
      color_2 = Color::RGB.new(rand(0..0xFF), rand(0..0xFF), rand(0..0xFF))
      set_colors(color_1, color_2)
    end

    def alarm_state
      time = Time.parse(@state.split(' ')[1])
      if Time.now < time
        on_state
      else
        random_state
      end
    end

    def handle_state
      if @old_state != @state
        @values = nil
        @wait = 100000000000000
      end
      case @state.split(' ').first
      when 'off'   then off_state
      when 'random'then random_state
      when 'on'    then on_state
      when 'blink' then blink_state
      when 'ping'  then ping_state
      when 'alarm' then alarm_state
      end
    end

    def run
      @logger.info 'started'
      loop do
        begin
          read_state
          handle_state
          sleep 1/33.0
        rescue => e
          @logger.error e.message
          sleep 10
          init
        end
      end
    end
  end
end
