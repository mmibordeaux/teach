class TeachingModulesController < ApplicationController
  before_action :set_teaching_module, only: [:show, :edit, :update, :destroy]

  # GET /teaching_modules
  # GET /teaching_modules.json
  def index
    @teaching_modules = TeachingModule.all.order(:semester_id)
    @student_hours = Involvement.student_hours
    @teacher_hours = Involvement.teacher_hours
    @title = 'Modules'
  end

  def summary
    @semesters = Semester.all
    @title = 'Maquette'
  end

  def costs
    @semesters = Semester.all
  end

  # GET /teaching_modules/1
  # GET /teaching_modules/1.json
  def show
    @title = @teaching_module.full_name
  end

  # GET /teaching_modules/new
  def new
    @teaching_module = TeachingModule.new
  end

  # GET /teaching_modules/1/edit
  def edit
  end

  # POST /teaching_modules
  # POST /teaching_modules.json
  def create
    @teaching_module = TeachingModule.new(teaching_module_params)

    respond_to do |format|
      if @teaching_module.save
        format.html { redirect_to @teaching_module, notice: 'Teaching module was successfully created.' }
        format.json { render :show, status: :created, location: @teaching_module }
      else
        format.html { render :new }
        format.json { render json: @teaching_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teaching_modules/1
  # PATCH/PUT /teaching_modules/1.json
  def update
    respond_to do |format|
      if @teaching_module.update(teaching_module_params)
        format.html { redirect_to @teaching_module, notice: 'Teaching module was successfully updated.' }
        format.json { render :show, status: :ok, location: @teaching_module }
      else
        format.html { render :edit }
        format.json { render json: @teaching_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teaching_modules/1
  # DELETE /teaching_modules/1.json
  def destroy
    @teaching_module.destroy
    respond_to do |format|
      format.html { redirect_to teaching_modules_url, notice: 'Teaching module was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teaching_module
      @teaching_module = TeachingModule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def teaching_module_params
      params.require(:teaching_module).permit(:code, :label, :objectives, :content, :how_to, :what_next, :hours, :semester_id, :teaching_subject_id, :teaching_unit_id, :teaching_category_id, :user_id, :coefficient, field_ids: [] )
    end
end
