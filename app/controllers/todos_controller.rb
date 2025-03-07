# app/controllers/todos_controller.rb
class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy]

  def index
    if params[:date].blank?
      redirect_to todos_path(date: Date.current) and return
    end

    @date = Date.parse(params[:date])

    # Redirect if the date is outside the allowed 7-day range
    if (@date - Date.current).abs > 7
      flash[:alert] = "Date is out of range."
      redirect_to todos_path(date: Date.current) and return
    end

    @todos = Todo.where(due_date: @date)

    respond_to do |format|
      format.html # index.html.erb
      format.turbo_stream { render "todos/index", locals: { todos: @todos, date: @date } }
    end
  end

  def by_date
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current

    # Redirect if the date is outside the allowed 7-day range
    if (@date - Date.current).abs > 7
      redirect_to todos_path(date: Date.current), alert: "Date is outside the allowed range." and return
    end

    @todos = Todo.where(due_date: @date)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("todos", partial: "todos/todo", locals: { todos: @todos, date: @date }) }
      format.html { render :index, locals: { date: @date } }
    end
  end

  def show
    @todo = Todo.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream { render "todos/show", locals: { todo: @todo } }
    end
  end

  def new
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @todo = Todo.new(due_date: @date)
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

    if @todo.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to by_date_todos_path(date: @todo.due_date), notice: "Todo created successfully." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @todo.update(todo_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to by_date_todos_path(date: @todo.due_date), notice: "Todo updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("modal", partial: "todos/form", locals: { todo: @todo }), status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def toggle_status
    @todo = Todo.find(params[:id])
    @todo.update(status: params[:status])

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@todo) }
      format.json { render json: { success: true } }
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @todo.destroy

    @todos = Todo.where(due_date: @date)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to by_date_todos_path(date: @date), notice: "Todo deleted successfully." }
    end
  end

  private
    def set_todo
      @todo = Todo.find(params[:id])
    end

    def todo_params
      params.require(:todo).permit(:title, :description, :status, :priority, :due_date)
    end
end