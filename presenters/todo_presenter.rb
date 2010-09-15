# encoding: utf-8
class TodoPresenter < Sinatra::Presenter::Base
  def render
    content_tag :ul, :class => 'actions' do
      link_to('+ task', '/todo/tasks/new') +
      link_to('edit tasks', '/todo/edit')
    end

    content_tag :ul, :class => 'tasks' do 
      rsc[:tasks].each { |task| details_for task }
    end

    content_tag :ul, :class => 'fires' do
      rsc[:fires].each { |fire| details_for fire }
    end
    self.layout
  end

  def render_form
    form :action => "/todo/#{rsc['_id']}", :_method => "put" do
      ul do
        rsc['tasks'].each_with_index do |task, i|
          li do 
            tag :input,
              :type   => 'text', 
              :value  => task['name'],
              :name   => "[tasks][#{i}][name]"
          end
        end
        li do tag :input, :type => 'submit', :value => 'submit' end
      end
    end
    self.layout
  end

  def render_task_form
    form :action => "/todo/#{rsc['_id']}/tasks", :_method => "post" do
      ul do
        li do tag :input, :type => 'text', :name => '[task][name]' end
        li do tag :input, :type => 'submit', :value => 'submit' end
      end
    end
    self.layout
  end
end
