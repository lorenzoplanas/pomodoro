# encoding: utf-8
class InventoryPresenter < Sinatra::Presenter::Base
  def render
    content_tag :ul, :class => 'tasks' do 
      rsc[:tasks].each { |task| details_for task }
    end
    self.layout
  end
end
