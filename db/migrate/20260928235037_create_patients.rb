class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.string :name
      t.date :date_of_birth
      t.string :phone
      t.string :email
      t.text :notes

      t.timestamps
    end
  end
end
