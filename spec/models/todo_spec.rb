# encoding: utf-8
require 'spec_helper'

describe Todo do
  context "validations : " do
    describe "defaults : " do
      it "should populate a created_at time" do
      end

      it "should have an empty tasks array" do
      end

      it "should have an empty fires array" do
      end

      describe "tasks : " do
        it "should have completed set to false" do
        end

        it "should have _id set to an ObjectId" do
        end

        it "should have estimated set to 0" do
        end

        it "should have pomodoros set to 0" do
        end

        it "should have done set to false" do
        end
      end
    end

    describe "presence : " do
      it "shouldn't be valid if account_id missing" do
        %w{ account_id }.each do |field|
          todo = Todo.new(:account_id => BSON::ObjectId.new)
          todo[field.to_sym] = nil
          todo.valid?.should be_false
          todo.errors.include?([field.to_sym, 'blank']).should be_true
          todo[:account_id] = BSON::ObjectId.new
          todo.valid?.should be_true
        end
      end

      it "shouldn't be valid if task name missing" do
        todo = Todo.new(:account_id => BSON::ObjectId.new)
        todo[:tasks] = [ { '_id' => BSON::ObjectId.new, } ]
        todo.valid?.should be_false
        todo.errors.include?([:task_name, 'blank']).should be_true
      end
    end

    describe "format : account_id " do
      it "should be a BSON::ObjectId instance" do
        todo = Todo.new(:account_id => BSON::ObjectId.new.to_s)
        todo.valid?.should be_false
        todo.errors.include?([:account_id, "format"]).should be_true
      end
    end

    describe "format : task" do
      it "_id should be a BSON::ObjectId instance" do
        todo = Todo.new(:account_id => BSON::ObjectId.new)
        todo[:tasks] = [ { 
          '_id'        => BSON::ObjectId.new.to_s, 
          'name'       => 'Task 1', 
          'position'   => 0 
        } ]
        todo.valid?.should be_false
        todo.errors.include?([:task_id, "format"]).should be_true
        todo[:tasks][0]['_id'] =  BSON::ObjectId.new
        todo.valid?.should be_true
      end

      it "estimated should be an Integer" do
        todo = Todo.new(:account_id => BSON::ObjectId.new)
        todo[:tasks] = [ {
          '_id'        => BSON::ObjectId.new, 
          'name'       => 'Task 1', 
          'position'   => 0,
          'estimated'  => '5'
        } ]
        todo.valid?.should be_false
        todo.errors.include?([:task_estimated, "format"]).should be_true
        todo[:tasks][0]['estimated'] = 5
        todo.valid?.should be_true
      end

      it "deadline should be a Time" do
        todo = Todo.new('account_id' => BSON::ObjectId.new)
        todo['tasks'] = [ {
          '_id'        => BSON::ObjectId.new, 
          'name'       => 'Task 1', 
          'position'   => 0,
          'estimated'  => 5,
          'deadline'   => Time.now.to_s
        } ]
        todo.valid?.should be_false
        todo.errors.include?([:task_deadline, "format"]).should be_true
        todo['tasks'][0]['deadline'] = Time.now.utc
        todo.valid?.should be_true
      end
    end
  end

  context "feature methods: " do
    before :each do
      @todo = Todo.new(
        :account_id => @account['_id'],
        :tasks      => [
          { '_id'       => BSON::ObjectId.new,
            'name'      => 'Task 1',
            'position'  => 0, 
            'pomodoros' => 3,
            'estimated' => 4 
          },
          { '_id'       => BSON::ObjectId.new,
            'name'      => 'Task 2',
            'position'  => 1,
            'pomodoros' => 4,
            'estimated' => 4,
            'done'      => true
          }
        ]
      )
      @todo.insert!
    end

    after :each do
      @todo.remove!
    end

    describe "#account" do
      it "should return the linked Account instance" do
        @todo.account.should == Account.find_one(@account['_id'])
      end
    end

    describe "#get_task" do
    end

    describe "#get_task_index" do
    end

    describe "#get_task_with_index" do
    end

    describe "#add_task" do
      it "should add the task at the last position in the list by default" do
        @todo.add_task( {
          'name'       => 'Task 3',
          'estimated'  => 3
        } )
        @todo.update
        @todo['tasks'][2]['name'].should == 'Task 3'
      end

      it "should add the task at the passed index" do
        @todo.add_task( {
          'name'       => 'Task 3',
          'estimated'  => 3
        }, 1)
        @todo.update
        @todo['tasks'][0]['name'].should == 'Task 1'
        @todo['tasks'][1]['name'].should == 'Task 3'
        @todo['tasks'][2]['name'].should == 'Task 2'
      end
    end

    describe "#remove_task" do
      it "should remove the task matching the id" do
        @todo.remove_task( @todo['tasks'][0]['_id'] )
        @todo['tasks'].length.should == 1
        @todo['tasks'][0]['name'].should == 'Task 2'
      end 
    end

    describe "#inc_estimated" do
      it "should increment estimated pomodoros for the task" do
        @todo['tasks'][0]['estimated'].should == 4 
        @todo.inc_estimated(@todo['tasks'][0]['_id'])
        @todo['tasks'][0]['estimated'].should == 5 
      end

      it "shouldn't go higher than 7" do
        10.times do 
          @todo.inc_estimated(@todo['tasks'][0]['_id'])
        end
        @todo['tasks'][0]['estimated'].should == 7
      end
    end

    describe "#dec_estimated" do
      it "should decrement estimated pomodoros for the task" do
        @todo['tasks'][0]['estimated'].should == 4 
        @todo['tasks'][0]['pomodoros'].should == 3
        @todo.dec_estimated(@todo['tasks'][0]['_id'])
        @todo['tasks'][0]['estimated'].should == 3
      end

      it "shouldn't go lower than the tasks' pomodoros" do
        @todo['tasks'][0]['estimated'].should == 4
        @todo['tasks'][0]['pomodoros'].should == 3
        10.times do
          @todo.dec_estimated(@todo['tasks'][0]['_id'])
        end
        @todo['tasks'][0]['estimated'].should == 3
      end

      it "shouldn't go lower than 1" do
        @todo['tasks'][0]['pomodoros'] = 0
        @todo['tasks'][0]['estimated'].should == 4 
        10.times do
          @todo.dec_estimated(@todo['tasks'][0]['_id'])
        end
        @todo['tasks'][0]['estimated'].should == 1
      end
    end

    describe "#inc_pomodoros" do
      it "should increment pomodoros pomodoros for the task" do
        @todo['tasks'][0]['pomodoros'].should == 3 
        @todo.inc_pomodoros(@todo['tasks'][0]['_id'])
        @todo['tasks'][0]['pomodoros'].should == 4 
      end

      it "shouldn't go higher than 7" do
        @todo['tasks'][0]['estimated'] = 7
        10.times do 
          @todo.inc_pomodoros(@todo['tasks'][0]['_id'])
        end
        @todo['tasks'][0]['pomodoros'].should == 7
      end

      it "shouldn't go higher than task's estimated" do
        @todo['tasks'][0]['estimated'] = 6
        10.times do 
          @todo.inc_pomodoros(@todo['tasks'][0]['_id'])
        end
        @todo['tasks'][0]['pomodoros'].should == 6
      end
    end

    describe "#dec_pomodoros" do
      it "should decrement pomodoros pomodoros for the task" do
        @todo['tasks'][0]['pomodoros'].should == 3 
        @todo.dec_pomodoros(@todo['tasks'][0]['_id'])
        @todo['tasks'][0]['pomodoros'].should == 2 
      end

      it "shouldn't go lower than 0" do
        @todo['tasks'][0]['pomodoros'].should == 3 
        10.times do
          @todo.dec_pomodoros(@todo['tasks'][0]['_id'])
        end
        @todo['tasks'][0]['pomodoros'].should == 0 
      end
    end

    describe "#check_task" do
      it "should set done to true" do
        @todo['tasks'][0]['done'].should be_false
        @todo.check_task(@todo['tasks'][0]['_id'])
        @todo['tasks'][0]['done'].should be_true
      end
    end

    describe "#uncheck_task" do
      it "should set done to true" do
        @todo['tasks'][1]['done'].should be_true
        @todo.uncheck_task(@todo['tasks'][1]['_id'])
        @todo['tasks'][1]['done'].should be_false
      end
    end
  end
end
