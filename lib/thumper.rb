require 'rubygems'
require 'hot_bunnies'
require 'mailbox'
require 'mostash'

require 'sinatra'

CONFIG = Mostash.new

CONFIG.env = ENV['THUMPER_ENV']

unless CONFIG.env == 'production'
  require 'dotenv'
  Dotenv.load
end

CONFIG.rabbit = {
  :enabled => ENV['WITHOUT_RABBIT'] || true,
  :broker => {
    :url => ENV['CLOUDAMQP_URL']
  },
  :inbound => {
    :exchange => {
      :name => "#{CONFIG.env.upcase}.TEST_MESSAGE",
      :opts => {
        :type => :fanout,
        :durable => true
      }
    },
    :queue => {
      :name => 'thumper.listener',
      :opts => {
        :durable => false,
        :auto_delete => true
      }
    }
  }
}

require 'java'
require 'uri'
Dir[File.dirname(__FILE__) + '/thumper/**/*.rb'].each { |f| require f }
