Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Rails.application.secrets.github_app_key, Rails.application.secrets.github_app_secret, scope: "user, repo"
end
