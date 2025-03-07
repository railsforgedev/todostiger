# test/integration/todos_flow_test.rb
require "test_helper"

class TodosFlowTest < ActionDispatch::IntegrationTest
  setup do
    @todo = todos(:today)
  end

  test "user can view todos for today" do
    get todos_path(date: Date.current)
    assert_response :success
    assert_select "h1", text: "Todos for Today"
  end

  test "user can create a todo" do
    assert_difference('Todo.count', 1) do
      post todos_path, params: {
        todo: {
          title: "New Todo",
          description: "Test Description",
          status: "pending",
          priority: "medium",
          due_date: Date.current
        }
      }, as: :turbo_stream
    end
    assert_response :success
  end

  test "user cannot create invalid todo" do
    assert_no_difference('Todo.count') do
      post todos_path, params: {
        todo: { title: "", description: "Invalid Test", status: "pending", priority: "medium", due_date: Date.current }
      }, as: :turbo_stream
    end
    assert_response :unprocessable_entity
  end

  test "user can update a todo" do
    patch todo_path(@todo), params: {
      todo: {
        title: "Updated Title",
        status: "completed"
      }
    }, as: :turbo_stream
    @todo.reload
    assert_equal "Updated Title", @todo.title
    assert_equal "completed", @todo.status
    assert_response :success
  end

  test "user cannot update with invalid attributes" do
    patch todo_path(@todo), params: { todo: { title: "" } }, as: :turbo_stream
    assert_response :unprocessable_entity
  end

  test "user can delete a todo" do
    assert_difference('Todo.count', -1) do
      delete todo_path(@todo), as: :turbo_stream
    end
    assert_response :success
  end

  test "user gets redirected for out-of-range dates" do
    get todos_path(date: (Date.current - 8.days))
    assert_redirected_to todos_path(date: Date.current)
    follow_redirect!
    assert_match(/Date is out of range\./, response.body)
  end
end
