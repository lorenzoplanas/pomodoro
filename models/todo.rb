# encoding: utf-8
class Todo < Mongomatic::Base
  extend Qsupport::Models::ClassMethods
  include Qsupport::Models::InstanceMethods

  def validate
    validates_presence_of :account_id
    self.errors << [:account_id, 'format'] unless 
      self['account_id'].kind_of?(BSON::ObjectId)

    self['tasks'].each do |t|
      self.errors << [:task_id, 'blank'] unless t['_id'].present?
      self.errors << [:task_name, 'blank'] unless t['name'].present?
      self.errors << [:task_id, 'format'] if 
        !t['_id'].kind_of?(BSON::ObjectId)
      self.errors << [:task_name, 'format'] if 
        !t['name'].kind_of?(String)
      self.errors << [:task_estimated, 'format'] if
        (t['estimated'].present? && !t['estimated'].kind_of?(Integer)) ||
        (t['estimated'] < 0) || (t['estimated'] > 7)
      self.errors << [:task_pomodoros, 'format'] if
        (t['pomodoros'].present? && !t['pomodoros'].kind_of?(Integer)) ||
        (t['pomodoros'] < 0) || (t['pomodoros'] > 7)
      self.errors << [:task_deadline, 'format'] if
        t['deadline'].present? && !t['deadline'].kind_of?(Time)
    end if self['tasks'].present?
  end

  def before_validate
    self['tasks']      ||= []
    self['fires']      ||= []
    self['created_at'] ||= Time.now.utc
    self['tasks'].each_with_index do |t, i|
      self['tasks'][i]['_id']       ||= BSON::ObjectId.new
      self['tasks'][i]['pomodoros'] ||= 0
      self['tasks'][i]['estimated'] ||= 1
      self['tasks'][i]['done']      ||= false
    end
  end

  def before_update
    self['updated_at'] ||= Time.now.utc
  end

  def account
    Account.find_one(self['account_id'])
  end

  def get_task(task_id)
    self['tasks'].each { |t| return t if t['_id'].to_s == task_id.to_s }
  end

  def get_task_index(task_id)
    self['tasks'].each_with_index do |t, i| 
      return i if t['_id'].to_s == task_id.to_s
    end
  end

  def get_task_with_index(task_id)
    self['tasks'].each_with_index do |t, i| 
      return [t, i] if t['_id'].to_s == task_id.to_s
    end
  end

  def add_task(task, position=nil)
    position ||= self['tasks'].length
    self['tasks'].insert(position, task)
  end
  
  def remove_task(task_id)
    self.pull 'tasks', self.get_task(task_id)
  end

  def inc_estimated(task_id)
    t, i = get_task_with_index(task_id)
    self.inc "tasks.#{i}.estimated", 1 if t['estimated'] < 7
  end

  def dec_estimated(task_id)
    t, i = get_task_with_index(task_id)
    if (t['estimated'] > 1) && (t['estimated'] > t['pomodoros'])
      self.inc "tasks.#{i}.estimated", -1 
    end
  end

  def inc_pomodoros(task_id)
    t, i = get_task_with_index(task_id)
    if (t['pomodoros'] < 7) && (t['pomodoros'] < t['estimated'])
      self.inc "tasks.#{i}.pomodoros", 1 
    end
  end

  def dec_pomodoros(task_id)
    t, i = get_task_with_index(task_id)
    self.inc "tasks.#{i}.pomodoros", -1 if t['pomodoros'] > 0
  end

  def check_task(task_id)
    self.set "tasks.#{get_task_index task_id}.done", true
  end

  def uncheck_task(task_id)
    self.set "tasks.#{get_task_index task_id}.done", false
  end

  def delete_task(task_id)
    t, i = get_task_with_index(task_id)
    self.pull "tasks", t
  end
end
