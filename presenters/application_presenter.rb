# encoding: utf-8
module ApplicationPresenter
  include Sinatra::Qsupport::Dispatcher
  include Qsupport::Presenters::CrumbHelper
  include Qsupport::Presenters::FieldHelper
  include Qsupport::Presenters::FormHelper
  include Qsupport::Presenters::InlineFormHelper
  include Qsupport::Presenters::HtmlHelper
  include Qsupport::Presenters::LocalizeHelper

  def details_for(task)
    content_tag :li, :class => 'task' do
      content_tag :span, task['name'],              :class => :name
      content_tag :span, task['deadline'],          :class => :deadline
      task_buttons_for task
      content_tag :span, :class => :pomodoros do
        print_pomodoros_for task
      end if task['pomodoros'].present?
    end
  end

  def print_pomodoros_for(task)
    (task['pomodoros'] - 1).times { content_tag :b }
    content_tag(:span, link_to('', "/todo/tasks/#{task['_id']}/dec_pomodoros",
    :class => 'full')) if task['pomodoros'] > 0

    if task['estimated'] > task['pomodoros']
      content_tag(:span, link_to('', "/todo/tasks/#{task['_id']}/inc_pomodoros",
      :class => 'clear')) if task['estimated'] >= 1
      (task['estimated'] - task['pomodoros'] - 1).times { content_tag :i }
    end
    nil
  end

  def task_buttons_for(task)
    content_tag :span, :class => 'buttons' do
      link_to('+ pomo', "/todo/tasks/#{task['_id']}/inc_estimated") +
      link_to('- pomo', "/todo/tasks/#{task['_id']}/dec_estimated") +
      link_to('x', "/todo/tasks/#{task['_id']}/delete_task") +
      if task['done']
        link_to('uncheck', "/todo/tasks/#{task['_id']}/uncheck_task")
      else
        link_to('check', "/todo/tasks/#{task['_id']}/check_task")
      end
    end
  end

  def layout
    "<html>
    <head>
      <title>Pomodoro :: Juice</title>
      <style type='text/css' media='all'>@import url('/css/app.css');</style>
    </head>

    <body>
      <div id='main'>
        #{self.page.content}
      </div>
      <div id='sidebar'>
      </div>
    </body>
    </html>"
  end
end
