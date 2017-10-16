class TeachingModulesController < ApplicationController
  load_and_authorize_resource

  def index
    @teaching_modules = TeachingModule.all.order(:semester_id)
    @student_hours = Involvement.student_hours
    @teacher_hours = Involvement.teacher_hours
    @title = 'Modules'
  end

  def summary
    @semesters = Semester.all
    @title = 'Maquette'
    @subtitle = 'Répartition des heures du point de vue étudiant'
  end

  def costs
    @semesters = Semester.all
    @title = 'Budget par module'
  end

  def show
    @title = @teaching_module.full_name
  end

  def new
    @teaching_module = TeachingModule.new
  end

  def edit
    @title = @teaching_module.full_name
  end

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

  def destroy
    @teaching_module.destroy
    respond_to do |format|
      format.html { redirect_to teaching_modules_url, notice: 'Teaching module was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def teaching_module_params
    params.require(:teaching_module).permit(:code, :label, :objectives, :content, :how_to, :what_next, :hours, :semester_id, :teaching_subject_id, :teaching_unit_id, :teaching_category_id, :user_id, :coefficient, field_ids: [] )
  end
end
