class Import < ApplicationRecord
  belongs_to :corpus
  has_many :chants

  def do!
    start!

    begin
      yield self
    rescue
      raise
    ensure
      finish!
    end
  end

  def start!
    raise 'already started' if started_at

    update! started_at: Time.now
  end

  def finish!
    raise 'already finished' if finished_at

    update! finished_at: Time.now
  end
end
