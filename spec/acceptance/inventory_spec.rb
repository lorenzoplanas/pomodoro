require 'spec_helper'

context 'inventory' do
  before :each do
    @inventory = Inventory.new(
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
    @inventory.insert!
  end

  after :each do
    @inventory.remove!
  end

  describe "index" do
    it 'should show a list of tasks' do
      visit '/inventory'
      page.should have_css('.tasks')
      page.should have_css('.task', :count => 2)
      page.should have_css('span.name', :count => 2)
      page.should have_css('span.deadline', :count => 2)
    end
  end
end
