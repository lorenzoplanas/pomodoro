# encoding: utf-8
require 'mongomatic'
require 'I18n'
require 'qsupport'

Mongomatic.db = Mongo::Connection.new(
  ENV['MONGO_HOST'], 
  ENV['MONGO_PORT']
).db(ENV['POMODORO_DB'])

Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |file| 
  require './models/' + File.basename(file, File.extname(file))
end

namespace :pomodoro do
  task :load do
    Mongomatic.db.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    
    @inventory = Inventory.new(
      :account_id => BSON::ObjectId.new,
      :tasks      => [
        { :_id        => BSON::ObjectId.new,
          :name       => 'Task 1',
          :estimated  => 2
        },
        { :_id        => BSON::ObjectId.new,
          :name       => 'Task 2',
          :estimated  => 5
        }
      ]
    )

    @inventory.insert!

    @todo = Todo.new(
      :account_id => BSON::ObjectId.new,
      :tasks      => [
        { :_id        => BSON::ObjectId.new,
          :name       => 'Task 1',
          :estimated  => 3,
          :pomodoros  => 3
        },
        { :_id        => BSON::ObjectId.new,
          :name       => 'Task 2',
          :estimated  => 4,
          :pomodoros  => 4
        }
      ]
    )
    @todo.insert!
  end
end
