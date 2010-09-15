require 'spec_helper'

context 'todo' do
  before :each do
    @todo = Todo.new(
      :account_id => BSON::ObjectId.new,
      :tasks      => [
        { :_id        => BSON::ObjectId.new,
          :name       => 'Task 1',
          :estimated  => 2,
          :position   => 0
        },
        { :_id        => BSON::ObjectId.new,
          :name       => 'Task 2',
          :estimated  => 5,
          :position   => 1 
        }
      ]
    )
    @todo.insert!
  end

  after :each do
    @todo.remove!
  end

  describe "index" do
    it 'should show a list of tasks' do
      visit '/todo'
      page.should have_css('.tasks')
      page.should have_css('.task', :count => 2)
      page.should have_css('span.name', :count => 2)
      page.should have_css('span.deadline', :count => 2)
    end
  end
end
