module Web
  class Thumper < Sinatra::Base
    get '/' do
      redirect to '/messages'
    end

    get '/messages' do
      @messages = ::Thumper::Listener.received_messages
      haml :messages, :format => :html5
    end
  end
end
