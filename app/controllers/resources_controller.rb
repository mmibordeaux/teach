class ResourcesController < ApplicationController
  load_and_authorize_resource

  def index
    @title = 'Ressources'
    breadcrumb
  end

  def show
    @title = @resource
    breadcrumb
  end

  def new
    @resource = Resource.new
    breadcrumb
    add_breadcrumb 'Nouvelle ressource'
  end

  def edit
    @title = "#{@resource} - Modifier"
    breadcrumb
    add_breadcrumb 'Modifier'
  end

  def create
    @resource = Resource.new(resource_params)
    if @resource.save
      redirect_to @resource, notice: "Resource was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @resource.update(resource_params)
      redirect_to @resource, notice: "Resource was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    redirect_to resources_url, notice: "Resource was successfully destroyed."
  end

  protected

  def breadcrumb
    add_breadcrumb 'Ressources', :resources_path
    add_breadcrumb @resource, @resource if @resource&.persisted?
  end

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.require(:resource).permit(:label, :code, :description, :hours_cm, :hours_td, :hours_tp, :code_apogee, :semester_id)
  end
end
