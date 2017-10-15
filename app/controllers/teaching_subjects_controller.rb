class TeachingSubjectsController < ApplicationController
  before_action :set_teaching_subject, only: [:show, :edit, :update, :destroy]

  # GET /teaching_subjects
  # GET /teaching_subjects.json
  def index
    @teaching_subjects = TeachingSubject.all
    @title = 'Sujets'
  end

  # GET /teaching_subjects/1
  # GET /teaching_subjects/1.json
  def show
  end

  # GET /teaching_subjects/new
  def new
    @teaching_subject = TeachingSubject.new
  end

  # GET /teaching_subjects/1/edit
  def edit
  end

  # POST /teaching_subjects
  # POST /teaching_subjects.json
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

  # PATCH/PUT /teaching_subjects/1
  # PATCH/PUT /teaching_subjects/1.json
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

  # DELETE /teaching_subjects/1
  # DELETE /teaching_subjects/1.json
  def destroy
    @teaching_subject.destroy
    respond_to do |format|
      format.html { redirect_to teaching_subjects_url, notice: 'Teaching subject was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teaching_subject
      @teaching_subject = TeachingSubject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def teaching_subject_params
      params.require(:teaching_subject).permit(:label, :teaching_unit_id)
    end
end
