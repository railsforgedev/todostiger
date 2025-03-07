require "application_system_test_case"

class TodosTest < ApplicationSystemTestCase
  setup do
    @todo = todos(:today) # Ensure you have a fixture named 'today'
  end

  test "user views today's todos" do
    visit todos_path
    assert_text "Todos for Today"
    assert_text @todo.title
  end

  test "user gets redirected for out-of-range dates" do
    visit todos_path(date: (Date.current - 8.days).to_s)
    assert_current_path todos_path(date: Date.current.to_s)
    assert_text "Date is out of range."
  end

  test "user creates a new todo" do
    visit todos_path
    click_on "New Todo"

    fill_in "Title", with: "Selenium Test Todo"

    # Find the Trix editor and input text
    find("trix-editor").set("This is a test todo.")

    select "Pending", from: "todo_status"
    select "Medium", from: "todo_priority"
    fill_in "todo_due_date", with: Date.current.to_s

    click_on "Create Todo"

    assert_text "Selenium Test Todo"
  end

  test "user edits a todo" do
    visit todos_path
    within("#todo_#{@todo.id}") do
      click_on "Edit"
    end

    fill_in "Title", with: "Updated Selenium Todo"
    click_on "Update Todo" # Ensure correct button text

    assert_text "Updated Selenium Todo"
  end

  test "user deletes a todo" do
    visit todos_path
    accept_confirm do
      within("#todo_#{@todo.id}") do
        click_on "Delete"
      end
    end

    assert_no_text @todo.title
  end
end
