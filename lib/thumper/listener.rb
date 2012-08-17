module Thumper
  class Listener
    include Mailbox

    def initialize
      trap("SIGINT") { @running = false }
    end

    def run!
      @running = true
      @subscription = BunnyRabbit.listen do |headers, msg|
        handle msg
      end
      while @running; end
      puts 'run returning'
    end

    def shutdown
      puts "Shutting down: #{@running}"
      @subscription.shutdown! && @subscription = nil if @subscription
      BunnyRabbit.close
    end

    private

    mailslot
    def handle msg
      puts "Message received: #{Time.now}:"
      puts msg.to_s
      puts
    end
  end
end
