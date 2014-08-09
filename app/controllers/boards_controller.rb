class BoardsController < ApplicationController
  include Authenticator
  before_action :reset_return_to, only: [:index, :new, :show, :destroy]

  def index
    session[:return_to] = nil
    @boards = Board.includes(:user).where(user: current_user).where(is_public: false).order(:name)
    @public_boards = Board.includes(:user).where(is_public: true).order(:name)
  end

  def new
    @board = Board.new
    defaults = {'stage:in-queue' => 'In Queue',
      'stage:development' => 'Development',
      'stage:testing' => 'Testing',
      'stage:testing-done' => 'Testing Done',
      'stage:ready-to-release' => 'Ready to Release',
      'stage:done' => 'Done'
    }
    index = 1;
    defaults.each do |key, val|
      @board.stages.build(github_label: key, name: val, ui_sort_order: index)
      index = index+1
    end
  end

  def create
    @board = Board.new(board_params)
    @board.user = current_user
    if @board.save
      redirect_to kanban_board_path(@board)
    else
      render :new
    end
  end

  def show
    @board = Board.friendly.find(params[:id])

    render layout: "kanban"
  end

  def edit
    @board = Board.friendly.find(params[:id])
    session[:return_to] = request.referer
  end

  def update
    @board = Board.friendly.find(params[:id])
    @board.update_attributes(board_params)
    redirect_to session[:return_to] || kanban_board_path(@board)
  end

  def destroy
    board = Board.friendly.find(params[:id])
    board.destroy
    redirect_to boards_path
  end

  def copy
    board = Board.friendly.find(params[:id])

    new_board = board.dup
    new_board.name = "Copy of #{board.name}"
    new_board.save!

    board.repositories.each do |repo|
      new_repo = repo.dup
      new_repo.milestone_id = nil
      new_board.repositories << new_repo
      new_repo.save!
    end

    board.stages.each do |stage|
      new_stage = stage.dup
      new_board.stages << new_stage
      new_stage.save!
    end

    redirect_to edit_board_path(new_board)
  end

  private
    def board_params
      params.require(:board).permit(:name, :milestone, :is_public,
                                repositories_attributes: [:id, :url, :_destroy],
                                stages_attributes: [:id, :name, :github_label, :ui_sort_order, :_destroy])
    end

    def reset_return_to
      session[:return_to] = nil
    end
end
