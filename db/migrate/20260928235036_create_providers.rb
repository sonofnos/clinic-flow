class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :providers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :specialty
      t.text :bio

      t.timestamps
    end
  end
end
