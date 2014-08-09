class User < ActiveRecord::Base
  has_many :boards

  def self.find_or_create_from_auth_hash(auth_hash)
    user = User.where(provider: auth_hash['provider'], uid: auth_hash['uid']).first
    if user.nil?
      user = create! do |user|
        user.provider = auth_hash['provider']
        user.uid = auth_hash['uid']
        user.name = auth_hash['info']['name'] || auth_hash['info']['nickname']
        user.token = auth_hash['credentials']['token']
        user.nickname = auth_hash['info']['nickname']
        user.email = auth_hash['info']['email']
        user.image_url = auth_hash['info']['image']
      end
    else
      user.token = auth_hash['credentials']['token']
      user.name = auth_hash['info']['name'] || auth_hash['info']['nickname']
      user.nickname = auth_hash['info']['nickname']
      user.email = auth_hash['info']['email']
      user.image_url = auth_hash['info']['image']
      user.save!
    end

    user
  end
end
