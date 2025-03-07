import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["todoItem", "statusText"];

  toggleStatus(event) {
    const todoId = event.target.dataset.todoId;
    const status = event.target.checked ? 2 : 0; // 2 = Completed, 1 = In Progress, 0 = Pending

    fetch(`/todos/${todoId}/toggle_status`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
      },
      body: JSON.stringify({ status: status })
    }).then(response => {
      if (response.ok) {
        // Update status text
        this.statusTextTarget.textContent = status === 2 ? "(Completed, " + this.statusTextTarget.textContent.split(", ")[1] : "(Pending, " + this.statusTextTarget.textContent.split(", ")[1];

        // Apply or remove strikethrough
        if (status === 2) {
          this.todoItemTarget.classList.add("line-through", "text-gray-500");
        } else {
          this.todoItemTarget.classList.remove("line-through", "text-gray-500");
        }
      }
    });
  }

  showModal(event) {
    if (event.target.tagName === "INPUT") return; // Don't trigger modal on checkbox click
    const todoId = event.currentTarget.dataset.todoId;
    Turbo.visit(`/todos/${todoId}`, { frame: "modal" });
  }
}
