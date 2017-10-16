class TeachingUnitsController < ApplicationController
  load_and_authorize_resource

  def index
    @teaching_units = TeachingUnit.all
    @title = 'Unités d\'enseignement'
  end

  def show
  end

  def new
    @teaching_unit = TeachingUnit.new
  end

  def edit
  end

  def create
    @teaching_unit = TeachingUnit.new(teaching_unit_params)

    respond_to do |format|
      if @teaching_unit.save
        format.html { redirect_to @teaching_unit, notice: 'Teaching unit was successfully created.' }
        format.json { render :show, status: :created, location: @teaching_unit }
      else
        format.html { render :new }
        format.json { render json: @teaching_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @teaching_unit.update(teaching_unit_params)
        format.html { redirect_to @teaching_unit, notice: 'Teaching unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @teaching_unit }
      else
        format.html { render :edit }
        format.json { render json: @teaching_unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @teaching_unit.destroy
    respond_to do |format|
      format.html { redirect_to teaching_units_url, notice: 'Teaching unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def teaching_unit_params
    params.require(:teaching_unit).permit(:number)
  end
end
