# app/controllers/todos_controller.rb
class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy]
  before_action :restrict_past_changes, only: [:create, :destroy]

  def index
    @todos = Todo.today
    @date = Date.current
  end

  def by_date
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @todos = Todo.where(due_date: @date)

    respond_to do |format|
      format.turbo_stream
      format.html { render :index, locals: { date: @date } }
    end
  end

  def show
    # Using Turbo Stream to display the description
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @todo = Todo.new(due_date: Date.current)
  end

  def edit
    @todo = Todo.find(params[:id])
    respond_to do |format|
      format.html { render :edit }
      format.turbo_stream { render :edit }
    end
  end

  def create
    @todo = Todo.new(todo_params)
    @todo.due_date = Date.tomorrow if @todo.due_date > Date.today

    if @todo.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todos_path, notice: "Todo created successfully." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @todo.update(todo_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todos_path, notice: "Todo updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("modal", partial: "todos/form", locals: { todo: @todo }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def toggle_status
    @todo = Todo.find(params[:id])
    @todo.update(status: params[:status])

    respond_to do |format|
      format.turbo_stream
      format.json { render json: { success: true } }
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    date = @todo.created_at.to_date # Ensure we track the correct day's todos
    @todo.destroy

    @todos = Todo.where("DATE(created_at) = ?", date) # Fetch remaining todos for that day

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to todos_path, notice: "Todo deleted successfully." }
    end
  end

  private
    def set_todo
      @todo = Todo.find(params[:id])
    end

    def restrict_past_changes
      date = params[:date] ? Date.parse(params[:date]) : Date.today
      if date < Date.today
        respond_to do |format|
          format.html { redirect_to todos_path, alert: "You cannot modify past todos." }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages", partial: "shared/flash", locals: { message: "You cannot modify past todos.", type: :error }) }
        end
      end
    end

    def todo_params
      params.require(:todo).permit(:title, :description, :status, :priority, :due_date)
    end
end