module Thumper
  class Message
    attr_reader :body, :received_at

    def initialize body
      @body, @received_at = body, Time.now
    end

    def to_console_s
      "Message received at: #{@received_at}#{$/}#{@body}#{$/}"
    end
  end
end
