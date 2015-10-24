class KanbanBoardBuilder
  PAGE_SIZE = 100
  MAX_ITERATIONS = 5
  LOOKBACK_IN_MONTHS = 6.months.ago.iso8601

  def build(current_user, id)
    @client = Octokit::Client.new(access_token: current_user.token)

    @board = Board.includes(:repositories, :stages).where(slug: id).first
    @board.repositories.each do |repo|
      if @board.milestone.present?
        milestone = repo_milestone(repo)
        next if milestone.nil?

        @board.due_date = milestone.due_on if @board.due_date.nil?
      end

      options = {
        filter: 'all',
        state: 'all',
        per_page: PAGE_SIZE,
        direction: 'asc',
        since: "#{LOOKBACK_IN_MONTHS}"
      }
      options[:milestone] = milestone.number if @board.milestone.present?

      count = 1
      issues = @client.issues(repo.url, options)
      last_response = @client.last_response
      loop do
        issues.each do |issue|
          build_issue_card(issue, repo)
        end

        break if last_response.rels[:next].nil? || count >= MAX_ITERATIONS

        count += 1
        last_response = last_response.rels[:next].get
        issues = last_response.data
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
    if stage
      card.stage = stage
      stage.cards << card
    end
  end

  def other_labels_of_issue(issue)
    issue.labels.select do |label|
      stage = @board.stages.find{|stg| stg.github_label == label.name }
      stage.nil?
    end
  end

  def find_issue_stage(issue, stages)
    if issue.state == "closed"
      return stages.last if @board.move_closed_issues
      return nil
    end

    stage = stages.find do |stg|
      lbl = issue.labels.find{ |label| label.name == stg.github_label }
      !lbl.nil?
    end

    stage || (stages.first if @board.move_other_issues)
  end
end
