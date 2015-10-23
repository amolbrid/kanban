class KanbanBoardBuilder
  def build(current_user, id)
    @client = Octokit::Client.new(access_token: current_user.token)

    @board = Board.includes(:repositories, :stages).where(slug: id).first
    @board.repositories.each do |repo|
      if @board.milestone
        milestone = repo_milestone(repo)
        next if milestone.nil?

        @board.due_date = milestone.due_on if @board.due_date.nil?
      end

      options = {
        state: 'all',
        per_page: 100,
        direction: 'asc'
      }
      options[:milestone] = milestone.number if @board.milestone

      issues = @client.issues(repo.url, options)
      Rails.logger.info(">>>> Issues: #{issues.count}")

      issues.each do |issue|
        build_issue_card(issue, repo)
      end
    end

    @board
  end

  def repo_milestone(repo)
    return nil if @board.milestone.nil?

    milestones = @client.list_milestones(repo.url, state: 'all')
    milestones.find {|m| m.title == @board.milestone}
  end

  def build_issue_card(issue, repo)
    card = Card.new
    card.number = issue.number
    card.title = issue.title
    card.html_url = issue.html_url
    card.repo_url = repo.url
    card.labels = other_labels_of_issue(issue)
    card.assignee = issue.assignee.nil? ? "NA" : issue.assignee.login
    card.assignee_avatar_url = issue.assignee.nil? ? "NA" : issue.assignee.avatar_url

    stage = find_issue_stage(issue, @board.stages)
    card.stage = stage
    stage.cards << card
  end

  def other_labels_of_issue(issue)
    issue.labels.select do |label|
      stage = @board.stages.find{|stg| stg.github_label == label.name }
      stage.nil?
    end
  end

  def find_issue_stage(issue, stages)
    return stages.last if issue.state == "closed"

    stage = stages.find do |stg|
      lbl = issue.labels.find{ |label| label.name == stg.github_label }
      !lbl.nil?
    end

    stage || stages.first
  end
end
