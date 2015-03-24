class TeachingCategoriesController < ApplicationController
  before_action :set_teaching_category, only: [:show, :edit, :update, :destroy]

  # GET /teaching_categories
  # GET /teaching_categories.json
  def index
    @teaching_categories = TeachingCategory.all
  end

  # GET /teaching_categories/1
  # GET /teaching_categories/1.json
  def show
  end

  # GET /teaching_categories/new
  def new
    @teaching_category = TeachingCategory.new
  end

  # GET /teaching_categories/1/edit
  def edit
  end

  # POST /teaching_categories
  # POST /teaching_categories.json
  def create
    @teaching_category = TeachingCategory.new(teaching_category_params)

    respond_to do |format|
      if @teaching_category.save
        format.html { redirect_to @teaching_category, notice: 'Teaching category was successfully created.' }
        format.json { render :show, status: :created, location: @teaching_category }
      else
        format.html { render :new }
        format.json { render json: @teaching_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teaching_categories/1
  # PATCH/PUT /teaching_categories/1.json
  def update
    respond_to do |format|
      if @teaching_category.update(teaching_category_params)
        format.html { redirect_to @teaching_category, notice: 'Teaching category was successfully updated.' }
        format.json { render :show, status: :ok, location: @teaching_category }
      else
        format.html { render :edit }
        format.json { render json: @teaching_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teaching_categories/1
  # DELETE /teaching_categories/1.json
  def destroy
    @teaching_category.destroy
    respond_to do |format|
      format.html { redirect_to teaching_categories_url, notice: 'Teaching category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_teaching_category
      @teaching_category = TeachingCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def teaching_category_params
      params.require(:teaching_category).permit(:label)
    end
end
