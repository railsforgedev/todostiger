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
# test/models/todo_test.rb
require 'test_helper'

class TodoTest < ActiveSupport::TestCase
  test "should not save todo without title" do
    todo = Todo.new(status: :pending, priority: :medium, due_date: Date.current)
    todo.description = "Test description"
    assert_not todo.save, "Saved the todo without a title"
  end

  test "should not save todo without status" do
    todo = Todo.new(title: "Test", priority: :medium, due_date: Date.current)
    todo.description = "Test description"
    todo.status = nil
    assert_not todo.save, "Saved the todo without a status"
  end

  test "should not save todo without priority" do
    todo = Todo.new(title: "Test", status: :pending, due_date: Date.current)
    todo.description = "Test description"
    todo.priority = nil
    assert_not todo.save, "Saved the todo without a priority"
  end

  test "should not save todo without due_date" do
    todo = Todo.new(title: "Test", status: :pending, priority: :medium)
    todo.description = "Test description"
    assert_not todo.save, "Saved the todo without a due date"
  end

  test "should not save todo with duplicate title" do
    todo1 = Todo.new(title: "Duplicate Test", status: :pending, priority: :medium, due_date: Date.current)
    todo1.description = "Test description"
    todo1.save

    todo2 = Todo.new(title: "Duplicate Test", status: :pending, priority: :medium, due_date: Date.current)
    todo2.description = "Another test description"
    assert_not todo2.save, "Saved the todo with a duplicate title"
  end

  test "should define status enum with correct values" do
    assert_equal({ "pending" => 0, "in_progress" => 1, "completed" => 2 }, Todo.statuses)
  end

  test "should define priority enum with correct values" do
    assert_equal({ "low" => 0, "medium" => 1, "high" => 2, "urgent" => 3 }, Todo.priorities)
  end

  test "scope today should return todos for today" do
    todo_today = todos(:today)
    todo_yesterday = todos(:yesterday)

    assert_includes Todo.today, todo_today
    assert_not_includes Todo.today, todo_yesterday
  end

  test "scope yesterday should return todos for yesterday" do
    todo_today = todos(:today)
    todo_yesterday = todos(:yesterday)

    assert_includes Todo.yesterday, todo_yesterday
    assert_not_includes Todo.yesterday, todo_today
  end

  test "scope tomorrow should return todos for tomorrow" do
    todo_today = todos(:today)
    todo_tomorrow = todos(:tomorrow)

    assert_includes Todo.tomorrow, todo_tomorrow
    assert_not_includes Todo.tomorrow, todo_today
  end

  test "scope for_date should return todos for specific date" do
    todo_today = todos(:today)
    todo_yesterday = todos(:yesterday)

    assert_includes Todo.for_date(Date.current), todo_today
    assert_includes Todo.for_date(Date.current - 1.day), todo_yesterday
    assert_not_includes Todo.for_date(Date.current), todo_yesterday
  end

  test "scope completed should return completed todos" do
    todo_completed = todos(:completed)
    todo_pending = todos(:today)

    assert_includes Todo.completed, todo_completed
    assert_not_includes Todo.completed, todo_pending
  end

  test "scope urgent should return urgent todos" do
    todo_urgent = todos(:urgent)
    todo_medium = todos(:today)

    assert_includes Todo.urgent, todo_urgent
    assert_not_includes Todo.urgent, todo_medium
  end
end