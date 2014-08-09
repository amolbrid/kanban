require 'octokit'

class KanbansController < ApplicationController
  include Authenticator
  include ActionView::Helpers::DateHelper

  def board
    Octokit.auto_paginate = true

    @board = Board.includes(:repositories, :stages).where(slug: params[:id]).first
    repos = @board.repositories
    stages = @board.stages

    client = Octokit::Client.new(access_token: current_user.token)

    repos.each do |repo|
      milestones = client.list_milestones(repo.url, state: 'all')
      milestone = milestones.select {|m| m.title == @board.milestone}

      next if milestone.first.nil?

      @board.due_date = milestone.first.due_on if @board.due_date.nil?

      issues = client.issues(repo.url, milestone: milestone.first.number, state: 'all', per_page: 100, direction: 'asc')
      issues.each do |issue|
        card = Card.new
        card.number = issue.number
        card.title = issue.title
        card.html_url = issue.html_url
        card.stage = assign_card_stage(issue, stages)
        card.repo_url = repo.url
        card.stage.cards << card

        card.labels = issue.labels.select do |label|
          stage = stages.find{|stage| stage.github_label == label.name }
          stage.nil?
        end

        card.assignee = issue.assignee.nil? ? "NA" : issue.assignee.login
        card.assignee_avatar_url = issue.assignee.nil? ? "NA" : issue.assignee.avatar_url
      end
    end

    render json: @board.to_json(include: [:repositories, :stages => { :include => :cards}])
  end

  def move_card
    @board = Board.friendly.find(params[:id]).first

    client = Octokit::Client.new(access_token: current_user.token)
    issue = client.issue(params[:repo_url], params[:number])
    labels = issue.labels.select {|lbl| lbl["name"] unless lbl["name"] == params[:prev_stage]}.push(params[:next_stage])

    options = {labels:labels, milestone: issue.milestone.number, state: issue.state}
    options[:assignee] = issue.assignee.login if issue.assignee

    client.update_issue(params[:repo_url], issue.number, issue.title, issue.body, options)

    render json: issue.number
  end

  private
    def assign_card_stage(issue, stages)
      if issue.state == "open"
        stage = stages.find do |stage|
          lbl = issue.labels.find{ |label| label.name == stage.github_label }
          !lbl.nil?
        end

        stage = stages.first if stage.nil?
      else
        stage = stages.last
      end

      stage
    end
end
