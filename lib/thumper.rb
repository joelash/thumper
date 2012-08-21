require 'rubygems'
require 'hot_bunnies'
require 'mailbox'
require 'mostash'

require 'sinatra'

CONFIG = Mostash.new

CONFIG.env = ENV['THUMPER_ENV']
CONFIG.rabbit = {
  :enabled => ENV['WITHOUT_RABBIT'] || true,
  :broker => {
    :url => ENV['CLOUDAMQP_URL'] || 'amqp://app6795846_heroku.com:ggZ9ywmvRTbPD-NfOMIcCr6KqywHviYy@tiger.cloudamqp.com/app6795846_heroku.com'
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
