# == Schema Information
#
# Table name: todos
#
#  id         :integer          not null, primary key
#  due_date   :date
#  priority   :integer
#  status     :integer
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Todo < ApplicationRecord
  # Associations
  has_rich_text :description
  # Enum definitions
  enum :status, { pending: 0, in_progress: 1, completed: 2 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }
  # Validations
  validates :title, presence: true, uniqueness: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :due_date, presence: true
  # Scopes for status
  scope :completed, -> { where(status: 2) }
  scope :in_progress, -> { where(status: 1) }
  scope :pending, -> { where(status: 0) }
  # Scopes for priority
  scope :urgent, -> { where(priority: 3) }
  scope :high, -> { where(priority: 2) }
  scope :medium, -> { where(priority: 1) }
  scope :low, -> { where(priority: 0) }
  # Scopes for date navigation
  scope :for_date, ->(date) { where(due_date: date) }
  scope :today, -> { for_date(Date.current) }
  scope :yesterday, -> { for_date(Date.current - 1.day) }
  scope :tomorrow, -> { for_date(Date.current + 1.day) }
end
