# app/controllers/todos_controller.rb
class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy]

  def index
    @todos = Todo.today
    @date = Date.current
  end

  def by_date
    @date = Date.parse(params[:date])

    # Ensure we're only allowing navigation within the 7-day limit
    today = Date.current
    if @date < (today - 7.days) || @date > (today + 7.days)
      redirect_to todos_path, alert: "You can only view todos within 7 days of today."
      return
    end

    @todos = Todo.for_date(@date)
    render :index
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

  def destroy
    @todo.destroy

    respond_to do |format|
      format.html { redirect_to todos_path, notice: "Todo was successfully deleted." }
      format.turbo_stream
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