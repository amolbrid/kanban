class Board < ActiveRecord::Base
  extend FriendlyId
  friendly_id :user_and_name, use: :slugged

  belongs_to :user

  has_many :repositories, inverse_of: :board, dependent: :delete_all
  has_many :stages, -> { order "ui_sort_order" }, inverse_of: :board, dependent: :delete_all

  accepts_nested_attributes_for :repositories, allow_destroy: true
  accepts_nested_attributes_for :stages, allow_destroy: true

  validates :name, :milestone, presence: true
  validate :name, uniqueness: { scope: :user, case_sensitive: false }

  def user_and_name
    "#{user.nickname}-#{name}"
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
