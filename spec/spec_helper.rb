# encoding: utf-8
require 'i18n'
require 'mongomatic'
require 'qsupport'
require 'bcrypt'
require 'rspec'
Mongomatic.db = Mongo::Connection.new(
  ENV['MONGO_HOST'], 
  ENV['MONGO_PORT']
).db('foo_test')

MODEL_DIR = File.join(File.dirname(__FILE__), "../models")
$LOAD_PATH.unshift(MODEL_DIR)
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), ".."))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

Dir[ File.join(MODEL_DIR, "*.rb") ].each do |file| 
  require File.basename(file)
end
require 'app'
require 'capybara'
require 'capybara/dsl'

Rspec.configure do |config|
  Capybara.app = Pomodoro.new
  config.include(Capybara)

  config.before :each do
    @account = Account.new( :name => 'Account 1')
    @account.insert!
  end

  config.after :each do
    @account.remove!
  end

  config.after :suite do
    Mongomatic.db.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
