class TeachingSubjectsController < ApplicationController
  load_and_authorize_resource

  add_breadcrumb 'Sujets', :teaching_subjects_path

  def index
    @teaching_subjects = TeachingSubject.all
    @title = 'Sujets'
  end

  def show
  end

  def new
    @teaching_subject = TeachingSubject.new
  end

  def edit
  end

  def create
    @teaching_subject = TeachingSubject.new(teaching_subject_params)

    respond_to do |format|
      if @teaching_subject.save
        format.html { redirect_to @teaching_subject, notice: 'Teaching subject was successfully created.' }
        format.json { render :show, status: :created, location: @teaching_subject }
      else
        format.html { render :new }
        format.json { render json: @teaching_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @teaching_subject.update(teaching_subject_params)
        format.html { redirect_to @teaching_subject, notice: 'Teaching subject was successfully updated.' }
        format.json { render :show, status: :ok, location: @teaching_subject }
      else
        format.html { render :edit }
        format.json { render json: @teaching_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @teaching_subject.destroy
    respond_to do |format|
      format.html { redirect_to teaching_subjects_url, notice: 'Teaching subject was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def teaching_subject_params
    params.require(:teaching_subject).permit(:label, :teaching_unit_id)
  end
end
