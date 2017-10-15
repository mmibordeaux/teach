class TeachingCategoriesController < ApplicationController
  def index
    @teaching_categories = TeachingCategory.all
    @title = 'Catégories'
  end

  def show
  end

  def new
    @teaching_category = TeachingCategory.new
  end

  def edit
  end

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

  def destroy
    @teaching_category.destroy
    respond_to do |format|
      format.html { redirect_to teaching_categories_url, notice: 'Teaching category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def teaching_category_params
    params.require(:teaching_category).permit(:label)
  end
end
