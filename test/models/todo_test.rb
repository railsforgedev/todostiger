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

require "test_helper"

class TodoTest < ActiveSupport::TestCase
  # === Validation Tests ===

  test "should not save todo without title" do
    todo = Todo.new(status: :pending, priority: :medium, due_date: Date.current, description: "Test description")
    assert_not todo.save, "Saved the todo without a title"
  end

  test "should not save todo without status" do
    todo = Todo.new(title: "Test", priority: :medium, due_date: Date.current, description: "Test description")
    todo.status = nil
    assert_not todo.save, "Saved the todo without a status"
  end

  test "should not save todo without priority" do
    todo = Todo.new(title: "Test", status: :pending, due_date: Date.current, description: "Test description")
    todo.priority = nil
    assert_not todo.save, "Saved the todo without a priority"
  end

  test "should not save todo without due_date" do
    todo = Todo.new(title: "Test", status: :pending, priority: :medium, description: "Test description")
    assert_not todo.save, "Saved the todo without a due date"
  end

  test "should not save todo with duplicate title" do
    Todo.create!(title: "Duplicate Test", status: :pending, priority: :medium, due_date: Date.current, description: "Test description")

    todo2 = Todo.new(title: "Duplicate Test", status: :pending, priority: :medium, due_date: Date.current, description: "Another test description")
    assert_not todo2.save, "Saved the todo with a duplicate title"
  end

  # === Enum Definition Tests ===

  test "status enum should be defined correctly" do
    expected_statuses = { "pending" => 0, "in_progress" => 1, "completed" => 2 }
    assert_equal expected_statuses, Todo.statuses, "Status enum is incorrect"
  end

  test "priority enum should be defined correctly" do
    expected_priorities = { "low" => 0, "medium" => 1, "high" => 2, "urgent" => 3 }
    assert_equal expected_priorities, Todo.priorities, "Priority enum is incorrect"
  end

  test "should allow valid status values" do
    todo = Todo.new(title: "Test Todo", due_date: Date.current, priority: :medium, description: "Test description")

    todo.status = :pending
    assert_equal "pending", todo.status

    todo.status = :in_progress
    assert_equal "in_progress", todo.status

    todo.status = :completed
    assert_equal "completed", todo.status
  end

  test "should allow valid priority values" do
    todo = Todo.new(title: "Test Todo", due_date: Date.current, status: :pending, description: "Test description")

    todo.priority = :low
    assert_equal "low", todo.priority

    todo.priority = :medium
    assert_equal "medium", todo.priority

    todo.priority = :high
    assert_equal "high", todo.priority

    todo.priority = :urgent
    assert_equal "urgent", todo.priority
  end

  test "should not allow invalid status values" do
    todo = Todo.new(title: "Test Todo", due_date: Date.current, priority: :medium, description: "Test description")
    assert_raises(ArgumentError) { todo.status = :invalid_status }
  end

  test "should not allow invalid priority values" do
    todo = Todo.new(title: "Test Todo", due_date: Date.current, status: :pending, description: "Test description")
    assert_raises(ArgumentError) { todo.priority = :invalid_priority }
  end

  # === Scope Tests ===

  test "today scope should return only today's todos" do
    assert_includes Todo.today, todos(:today)
    assert_not_includes Todo.today, todos(:yesterday)
    assert_not_includes Todo.today, todos(:tomorrow)
  end

  test "yesterday scope should return only yesterday's todos" do
    assert_includes Todo.yesterday, todos(:yesterday)
    assert_not_includes Todo.yesterday, todos(:today)
    assert_not_includes Todo.yesterday, todos(:tomorrow)
  end

  test "tomorrow scope should return only tomorrow's todos" do
    assert_includes Todo.tomorrow, todos(:tomorrow)
    assert_not_includes Todo.tomorrow, todos(:today)
    assert_not_includes Todo.tomorrow, todos(:yesterday)
  end

  test "for_date scope should return todos for specific date" do
    assert_includes Todo.for_date(Date.current), todos(:today)
    assert_includes Todo.for_date(Date.current - 1.day), todos(:yesterday)
    assert_includes Todo.for_date(Date.current + 1.day), todos(:tomorrow)
  end

  test "completed scope should return only completed todos" do
    assert_includes Todo.completed, todos(:completed)
    assert_not_includes Todo.completed, todos(:pending)
  end

  test "in_progress scope should return only in-progress todos" do
    assert_includes Todo.in_progress, todos(:in_progress)
    assert_not_includes Todo.in_progress, todos(:pending)
  end

  test "pending scope should return only pending todos" do
    assert_includes Todo.pending, todos(:pending)
    assert_not_includes Todo.pending, todos(:completed)
  end

  test "urgent scope should return only urgent todos" do
    assert_includes Todo.urgent, todos(:urgent)
    assert_not_includes Todo.urgent, todos(:medium)
  end

  test "high scope should return only high-priority todos" do
    assert_includes Todo.high, todos(:high)
    assert_not_includes Todo.high, todos(:low)
  end

  test "medium scope should return only medium-priority todos" do
    assert_includes Todo.medium, todos(:medium)
    assert_not_includes Todo.medium, todos(:high)
  end

  test "low scope should return only low-priority todos" do
    assert_includes Todo.low, todos(:low)
    assert_not_includes Todo.low, todos(:urgent)
  end
end
