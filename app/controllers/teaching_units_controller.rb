class TeachingUnitsController < ApplicationController
  before_action :set_teaching_unit, only: [:show, :edit, :update, :destroy]

  # GET /teaching_units
  # GET /teaching_units.json
  def index
    @teaching_units = TeachingUnit.all
    @title = 'Unités d\'enseignement'
  end

  # GET /teaching_units/1
  # GET /teaching_units/1.json
  def show
  end

  # GET /teaching_units/new
  def new
    @teaching_unit = TeachingUnit.new
  end

  # GET /teaching_units/1/edit
  def edit
  end

  # POST /teaching_units
  # POST /teaching_units.json
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

  # PATCH/PUT /teaching_units/1
  # PATCH/PUT /teaching_units/1.json
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

  # DELETE /teaching_units/1
  # DELETE /teaching_units/1.json
  def destroy
    @teaching_unit.destroy
    respond_to do |format|
      format.html { redirect_to teaching_units_url, notice: 'Teaching unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teaching_unit
      @teaching_unit = TeachingUnit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def teaching_unit_params
      params.require(:teaching_unit).permit(:number)
    end
end
