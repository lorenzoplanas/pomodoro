# encoding: utf-8
require 'spec_helper'

describe Inventory do

  context "validations : " do
    describe "defaults : " do
      it "should populate a created_at time" do
      end

      it "should have an empty tasks array" do
      end
    end

    describe "presence : " do
      it "shouldn't be valid if account_id missing" do
        %w{ account_id }.each do |field|
          inventory = Inventory.new(:account_id => BSON::ObjectId.new)
          inventory[field.to_sym] = nil
          inventory.valid?.should be_false
          inventory.errors.include?([field.to_sym, 'blank']).should be_true
          inventory[:account_id] = BSON::ObjectId.new
          inventory.valid?.should be_true
        end
      end

      it "shouldn't be valid if task name or position missing" do
        inventory = Inventory.new(:account_id => BSON::ObjectId.new)
        inventory[:tasks] = [ {
          :_id        => BSON::ObjectId.new, 
          :name       => 'Task 1', 
          :position   => 0 
        } ]
        %w{ name position }.each do |field|
          inventory.tasks[0][field.to_sym] = nil
          inventory.valid?.should be_false
          inventory.errors.include?(
            ["task_#{field}".to_sym, 'blank']
          ).should be_true
        end
      end
    end

    describe "format : account_id " do
      it "should be a BSON::ObjectId instance" do
        inventory = Inventory.new(:account_id => BSON::ObjectId.new.to_s)
        inventory.valid?.should be_false
        inventory.errors.include?([:account_id, "format"]).should be_true
      end
    end

    describe "format : task" do
      it "_id should be a BSON::ObjectId instance" do
        inventory = Inventory.new(:account_id => BSON::ObjectId.new)
        inventory[:tasks] = [ { 
          :_id        => BSON::ObjectId.new.to_s, 
          :name       => 'Task 1', 
          :position   => 0 
        } ]
        inventory.valid?.should be_false
        inventory.errors.include?([:task_id, "format"]).should be_true
        inventory[:tasks][0][:_id] =  BSON::ObjectId.new
        inventory.valid?.should be_true
      end

      it "position should be an Integer" do
        inventory = Inventory.new(:account_id => BSON::ObjectId.new)
        inventory[:tasks] = [ {
          :_id        => BSON::ObjectId.new, 
          :name       => 'Task 1', 
          :position   => '0'
        } ]
        inventory.valid?.should be_false
        inventory.errors.include?([:task_position, "format"]).should be_true
        inventory[:tasks][0][:position] = 0
        inventory.valid?.should be_true
      end

      it "estimated should be an Integer" do
        inventory = Inventory.new(:account_id => BSON::ObjectId.new)
        inventory[:tasks] = [ {
          :_id        => BSON::ObjectId.new, 
          :name       => 'Task 1', 
          :position   => 0,
          :estimated  => '5'
        } ]
        inventory.valid?.should be_false
        inventory.errors.include?([:task_estimated, "format"]).should be_true
        inventory[:tasks][0][:estimated] = 5
        inventory.valid?.should be_true
      end

      it "deadline should be a Time" do
        inventory = Inventory.new(:account_id => BSON::ObjectId.new)
        inventory[:tasks] = [ {
          :_id        => BSON::ObjectId.new, 
          :name       => 'Task 1', 
          :position   => 0,
          :estimated  => 5,
          :deadline   => Time.now.to_s
        } ]
        inventory.valid?.should be_false
        inventory.errors.include?([:task_deadline, "format"]).should be_true
        inventory[:tasks][0][:deadline] = Time.now.utc
        inventory.valid?.should be_true
      end
    end

    context "feature methods: " do
      before :each do
        @inventory = Inventory.new(
          :account_id => @account[:_id],
          :tasks      => [
            { :_id      => BSON::ObjectId.new,
              :name     => 'Task 1',
              :position => 0 
            },
            { :_id      => BSON::ObjectId.new,
              :name     => 'Task 2',
              :position => 1
            }
          ]
        )
        @inventory.insert!
        @inventory.reload
      end

      after :each do
        @inventory.remove!
      end

      describe "#account" do
        it "should return the linked Account instance" do
          @inventory.account.should == Account.find_one(@account[:_id])
        end
      end

      describe "#tasks" do
        it "should return tasks sorted by position" do
          @inventory.tasks.map {|t| t['name'] }.should == ['Task 1', 'Task 2']
        end
      end
    end
  end
end
