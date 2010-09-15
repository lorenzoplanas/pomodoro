# content: UTF-8
require 'sinatra/base'
require 'i18n'
require 'mongomatic'
require 'rack-flash'
require 'tzinfo'
require 'pony'
require 'sinatra_presenter'
require 'qsupport'
#require 'prawn'
#require 'prawn/measurement_extensions'
require './presenters/application_presenter'

I18n.load_path << ['i18n/en.yml', 'i18n/es.yml']
Mongomatic.db = Mongo::Connection.new(
  ENV['MONGO_HOST'], 
  ENV['MONGO_PORT']
).db(ENV['POMODORO_DB'])
Sinatra::Presenter::Base.class_eval { include ApplicationPresenter }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |file| 
  require './models/' + File.basename(file, File.extname(file))
end
Dir[File.dirname(__FILE__) + '/presenters/*.rb'].each do |file| 
  require './presenters/' + File.basename(file, File.extname(file))
end

class Pomodoro < Sinatra::Base
  #include Qsupport::Routes
  #helpers Sinatra::Qsupport::Authentication
  helpers Sinatra::Qsupport::Dispatcher
  helpers Sinatra::Qsupport::Localization
  helpers Sinatra::Presenter::Helpers

  use Rack::Flash
  set :environment,           :development
  set :app_file,              __FILE__
  set :root,                  File.dirname(__FILE__)
  set :public,                Proc.new { File.join(root, "public") }
  set :default_locale,        'en'
  set :home_path,             '/users'
  set :mobile_home_path,      '/mobile'
  set :login_path,            '/login'
  enable                      :sessions, :static, :method_override

  configure :production do 
    disable :show_exceptions
    not_found do 
      #set_encoding 
      present nil, :render, :class => "Error"
    end
    error  do 
      #set_encoding
      present nil, :render, :class => "Error" 
    end
  end

  before { set_encoding; objectidify(params); p params }
  after  { p params }

  put '/todo/:id' do
    @todo = Todo.find_one(BSON::ObjectId(params['id'].to_s))
    @todo['tasks'].each_with_index do |t, i|
      t.merge! params['tasks'][i.to_s]
    end
    @todo.update
    redirect '/todo'
  end

  post '/todo/:id' do
    @todo = Todo.find_one(BSON::ObjectId(params['id'].to_s))
    @todo['tasks'].each_with_index do |t, i|
      t.merge! params['tasks'][i.to_s]
    end
    @todo.update
    redirect '/todo'
  end

  post '/todo/:id/tasks' do
    @todo = Todo.find_one(BSON::ObjectId(params['id'].to_s))
    @todo.push "tasks", { 
      :_id        => BSON::ObjectId.new,
      :name       => params['task']['name'],
      :estimated  => 1,
      :pomodoros  => 0,
      :done       => false,
      :created_at => Time.now.utc
    }
    @todo.update
    redirect '/todo'
  end

  get '/inventory' do
    present Inventory.first, :render, :req => req
  end

  get '/todo' do
    present Todo.first, :render, :req => req
  end

  get '/todo/tasks/:id/:action' do
    Todo.first.send(params['action'], params['id'])
    redirect '/todo'
  end

  get '/todo/edit' do
    present Todo.first, :render_form, :req => req
  end

  get '/todo/tasks/new' do
    present Todo.first, :render_task_form, :req => req
  end
end
