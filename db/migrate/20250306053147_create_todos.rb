class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.string :title
      t.integer :status
      t.integer :priority
      t.date :due_date

      t.timestamps
    end
  end
end
