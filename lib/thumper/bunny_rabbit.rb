class BunnyRabbit
  class << self
    def listen &block
      queue.subscribe(:blocking => false) do |headers, msg|
        block.call headers, msg
        headers.ack
      end
    end

    def close
      if @channel
        puts 'closing rabbit channel'
        @channel.close
        @channel = nil
      end
      if @connection
        puts 'closing rabbit connection'
        @connection.close
        puts 'connection closed'
        @connection = nil
      end
      puts 'done shutting down'
    end

    private
    def connection
      @connection ||= begin
                        broker = CONFIG.rabbit.broker
                        puts "Connecting to rabbit broker: #{broker.url}"
                        uri = URI.parse broker.url
                        HotBunnies.connect :uri => broker.url
                      end
    end

    def channel
      @channel ||= connection.create_channel
    end

    def exchange
      @exchange ||= begin
                      exchange = CONFIG.rabbit.inbound.exchange
                      channel.exchange exchange.name, exchange.opts
                    end
    end

    def queue
      @queue ||= begin
                   queue = CONFIG.rabbit.inbound.queue
                   channel.queue(queue.name, queue.opts).tap do |q|
                     q.bind exchange, queue.bind_ops || {}
                   end
                 end
    end
  end
end
