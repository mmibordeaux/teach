class CompetenciesController < ApplicationController
  load_and_authorize_resource

  add_breadcrumb 'Compétences', :competencies_path

  def index
    @competencies = Competency.all
    @title = 'Compétences'
  end

  def show
    @title = @competency.to_s.truncate(40)
    add_breadcrumb @title
  end

  def new
    @competency = Competency.new
  end

  def edit
  end

  def create
    @competency = Competency.new(competency_params)

    respond_to do |format|
      if @competency.save
        format.html { redirect_to @competency, notice: 'Competency was successfully created.' }
        format.json { render :show, status: :created, location: @competency }
      else
        format.html { render :new }
        format.json { render json: @competency.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @competency.update(competency_params)
        format.html { redirect_to @competency, notice: 'Competency was successfully updated.' }
        format.json { render :show, status: :ok, location: @competency }
      else
        format.html { render :edit }
        format.json { render json: @competency.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @competency.destroy
    respond_to do |format|
      format.html { redirect_to competencies_url, notice: 'Competency was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def competency_params
    params.require(:competency).permit(:label, :teaching_module_id)
  end
end
