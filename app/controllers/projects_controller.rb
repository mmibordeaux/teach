class ProjectsController < ApplicationController
  load_and_authorize_resource

  add_breadcrumb 'Projets', :projects_path

  def index
    @projects = Project.all
    @title = 'Projets'
    @subtitle = 'Démarche pédagogique favorisant la transversalité'
  end

  def show
    @title = @project.to_s
    add_breadcrumb @project, @project
  end

  def new
    @project = Project.new
  end

  def edit
    add_breadcrumb @project, @project
    add_breadcrumb 'Modifier'
  end

  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def project_params
    params.require(:project).permit(:label, :description, :position, :user_id, field_ids: [], semester_ids: [], user_ids: [])
  end
end
