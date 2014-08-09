class Stage < ActiveRecord::Base
  attr_accessor :cards

  belongs_to :board, inverse_of: :stages

  validates :name, :github_label, presence: true

  after_initialize :init

  def init
    self.cards = []
  end
end
