class ChantChangeCorpusIdNotNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :chants, :corpus_id, false
  end
end
