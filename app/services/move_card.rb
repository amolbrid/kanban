class MoveCard
  def initialize(params, current_user)
    @params = params
    @current_user = current_user
  end

  def call
    @board = Board.friendly.find(params[:id])

    issue = client.issue(params[:repo_url], params[:number])

    labels = remove_current_swim_lane_label(issue)
    labels.push(params[:next_stage])

    options = {labels: labels, state: issue.state}
    options[:milestone] = issue.milestone.number if issue.milestone.present?
    options[:assignee] = issue.assignee.login if issue.assignee

    client.update_issue(params[:repo_url], issue.number, issue.title, issue.body, options)

    issue
  end

  private
    def remove_current_swim_lane_label(issue)
      issue.labels.select do |lbl|
        lbl["name"] unless lbl["name"] == params[:prev_stage]
      end
    end

    def client
      @client ||= Octokit::Client.new(access_token: @current_user.token)
    end

    def params
      @params
    end
end
