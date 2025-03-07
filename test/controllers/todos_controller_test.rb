# test/controllers/todos_controller_test.rb
require 'test_helper'

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @todo = todos(:today)
    @todo_yesterday = todos(:yesterday)
    @todo_tomorrow = todos(:tomorrow)
  end

  test "should get index" do
    get todos_url(date: Date.current.to_s)
    assert_response :success
  end

  test "should get by_date" do
    get todos_by_date_url(date: Date.current.to_s)
    assert_response :success
  end

  test "should redirect if date is outside 7-day limit" do
    get todos_by_date_url(date: (Date.current - 8.days).to_s)

    assert_response :redirect
    assert_includes [302, 303], response.status  # Allow both redirect statuses
    assert_redirected_to todos_url(date: Date.current.to_s)
    assert_not_nil flash[:alert]
  end

  test "should get new" do
    get new_todo_url
    assert_response :success
  end

  test "should create todo" do
    assert_difference('Todo.count') do
      post todos_url, params: {
        todo: {
          title: "New Test Todo",
          description: "New test description",
          status: "pending",
          priority: "medium",
          due_date: Date.current
        }
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should not create todo with invalid attributes" do
    assert_no_difference('Todo.count') do
      post todos_url, params: {
        todo: {
          title: "",
          description: "Invalid test",
          status: "pending",
          priority: "medium",
          due_date: Date.current
        }
      }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test "should show todo" do
    get todo_url(@todo), as: :turbo_stream
    assert_response :success
  end

  test "should get edit" do
    get edit_todo_url(@todo)
    assert_response :success
  end

  test "should update todo" do
    patch todo_url(@todo), params: {
      todo: {
        title: "Updated Test Todo",
        description: "Updated test description",
        status: "completed",
        priority: "high",
        due_date: @todo.due_date
      }
    }, as: :turbo_stream

    @todo.reload
    assert_equal "Updated Test Todo", @todo.title
    assert_equal "completed", @todo.status
    assert_equal "high", @todo.priority
    assert_response :success
  end

  test "should not update todo with invalid attributes" do
    patch todo_url(@todo), params: {
      todo: {
        title: "",
        description: @todo.description,
        status: @todo.status,
        priority: @todo.priority,
        due_date: @todo.due_date
      }
    }, as: :turbo_stream

    assert_response :unprocessable_entity
  end

  test "should destroy todo" do
    assert_difference('Todo.count', -1) do
      delete todo_url(@todo), as: :turbo_stream
    end

    assert_response :success
  end
end
