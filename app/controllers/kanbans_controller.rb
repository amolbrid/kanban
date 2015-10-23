require 'octokit'

class KanbansController < ApplicationController
  include Authenticator
  include ActionView::Helpers::DateHelper

  def board
    builder = KanbanBoardBuilder.new
    board =  builder.build(current_user, params[:id])

    render json: board.to_json(include: [:repositories, :stages => { :include => :cards}])
  end

  def move_card
    @board = Board.friendly.find(params[:id])

    client = Octokit::Client.new(access_token: current_user.token)
    issue = client.issue(params[:repo_url], params[:number])
    labels = issue.labels.select {|lbl| lbl["name"] unless lbl["name"] == params[:prev_stage]}.push(params[:next_stage])

    options = {labels:labels, milestone: issue.milestone.number, state: issue.state}
    options[:assignee] = issue.assignee.login if issue.assignee

    client.update_issue(params[:repo_url], issue.number, issue.title, issue.body, options)

    render json: issue.number
  end
end
