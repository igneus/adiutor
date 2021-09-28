class ChantsAddPitchSeriesIntervalSeries < ActiveRecord::Migration[6.1]
  def change
    change_table :chants do |t|
      t.string :pitch_series
      t.string :interval_series
    end
  end
end
