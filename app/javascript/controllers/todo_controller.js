import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["todoItem"];

  toggleStatus(event) {
    const checkbox = event.target;
    const todoId = checkbox.dataset.todoId;
    const completed = checkbox.checked;
    const todoItem = this.todoItemTargets.find(item => item.dataset.todoId === todoId);

    if (!todoId) {
      console.error("Todo ID is missing!");
      return;
    }

    fetch(`/todos/${todoId}/toggle_status`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ status: completed ? 2 : 1 })
    }).then(response => {
      if (response.ok) {
        todoItem.classList.toggle("line-through");
        todoItem.classList.toggle("text-gray-500");
      } else {
        alert("Failed to update status.");
      }
    });
  }
}
