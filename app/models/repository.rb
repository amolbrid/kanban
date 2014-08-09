class Repository < ActiveRecord::Base
  belongs_to :board, inverse_of: :repositories

  validates :url, presence: true

  def has_no_milestone?
    repo.milestone.nil?
  end
end
