class CreateFilms < ActiveRecord::Migration[5.0]
  def change
    create_table :films do |t|
    	t.string :name
    	t.string :date
    	t.string :category
    	t.string :rate

      t.timestamps
    end
  end
end
