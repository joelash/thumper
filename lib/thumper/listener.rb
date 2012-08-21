module Synchronizable
  def self.included base
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def synchronizer
      @synchronizer ||= Object.new.to_java
    end
  end

  module InstanceMethods
    def synchronized
      synchronizer.synchronized { yield }
    end

    def synchronizer
      self.class.synchronizer
    end
  end
end

module Thumper
  class Listener
    include Mailbox
    include Synchronizable

    def self.instance
      @instance ||= new
    end

    def self.received_messages
      instance.received_messages
    end

    def initialize
      trap("SIGINT") { @running = false }
    end
    private_class_method :new

    def run! continually = false
      @running = true
      @subscription = BunnyRabbit.listen do |headers, msg|
        handle msg
      end
      while @running; end if continually
    end

    def shutdown
      puts "Shutting down: #{@running}"
      @subscription.shutdown! && @subscription = nil if @subscription
      BunnyRabbit.close
    end

    def received_messages
      synchronized { messages.dup }
    end

    private

    mailslot
    def handle msg
      message = Message.new msg
      messages << message
      puts message.to_console_s
    end

    def messages
      synchronized { @messages ||= [] }
    end
  end
end
