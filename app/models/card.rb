class Card
  # include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :title, :number, :html_url, :stage, :assignee, :assignee_avatar_url, :labels, :repo_url

  def initialize()
    self.labels = []
  end

  def attributes
    {
      title: nil,
      number: nil,
      html_url: nil,
      labels: nil,
      stage: nil,
      assignee: nil,
      assignee_avatar_url:nil,
      repo_url: nil
    }
  end
end
