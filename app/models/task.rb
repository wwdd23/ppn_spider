class Task < ActiveRecord::Base
  validates_presence_of :url, :script_name, :project, :category

  scope :current_day, ->{ where(created_at: Time.now.beginning_of_day..Time.now.tomorrow.beginning_of_day)}

  CATEGORIES = ['normal', 'webkit', 'image']

  include AASM
  aasm :column => 'status' do
    state :undo, :intial => true
    state :delivered
    state :failed
    state :success

    event :deliver do
      transitions :from => :undo, :to => :delivered
    end

    event :reset do
      transitions :to => :undo
    end

    event :return_error do
      transitions :from => :delivered, :to => :undo, :on_transition => [:increase_attempts], :guard => :can_redeliver?
      transitions :from => :delivered, :to => :failed
    end

    event :return_data do
      transitions :from => :delivered, :to => :success
    end
  end

  private
  def can_redeliver?
    self.attempts < 3
  end

  def increase_attempts
    self.increment!(:attempts)
  end
end
