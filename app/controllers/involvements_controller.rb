class InvolvementsController < ApplicationController
  load_and_authorize_resource

  add_breadcrumb 'Planifications', :involvements_path

  def index
    @involvements = Involvement.all
  end

  def show
  end

  def new
    @involvement = Involvement.new
    @involvement.user_id = params[:user_id] if params.include? :user_id
    @involvement.teaching_module_id = params[:teaching_module_id] if params.include? :teaching_module_id
    @title = 'Planifier une intervention'
  end

  def edit
    @title = 'Modifier une planification'
  end

  def create
    @involvement = Involvement.new(involvement_params)

    respond_to do |format|
      if @involvement.save
        format.html { redirect_to @involvement.teaching_module, notice: 'Involvement was successfully created.' }
        format.json { render :show, status: :created, location: @involvement }
      else
        format.html { render :new }
        format.json { render json: @involvement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @involvement.update(involvement_params)
        format.html { redirect_to @involvement.teaching_module, notice: 'Involvement was successfully updated.' }
        format.json { render :show, status: :ok, location: @involvement }
      else
        format.html { render :edit }
        format.json { render json: @involvement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    teaching_module = @involvement.teaching_module
    @involvement.destroy
    respond_to do |format|
      format.html { redirect_to teaching_module, notice: 'Involvement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def involvement_params
    params.require(:involvement).permit(:teaching_module_id, :user_id, :project_id, :hours_cm, :hours_td, :hours_tp, :description, :multiplier_td, :multiplier_tp, :groups_tp)
  end
end
