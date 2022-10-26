class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports do |t|
      t.belongs_to :corpus, null: false, foreign_key: {to_table: :corpuses}
      t.timestamp :started_at, null: false
      t.timestamp :finished_at
      t.timestamps
    end

    add_belongs_to :chants, :import, foreign_key: true
  end
end
