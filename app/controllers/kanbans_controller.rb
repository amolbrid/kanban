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
    move_card = MoveCard.new(params, current_user)

    render json: move_card.call.number
  end
end
