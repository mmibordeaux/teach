class PromotionsController < ApplicationController
  load_and_authorize_resource

  add_breadcrumb 'Promotions', :promotions_path

  def index
    @promotions = Promotion.all
    @title = 'Promotions'
    @subtitle = 'Chaque année, de beaux étudiants bien frais'
  end

  def show
    @promotion.sync_events
    @title = @promotion.to_s
    @semesters = Semester.all
    @subtitle = 'Répartition des heures du point de vue étudiant'
    add_breadcrumb @promotion
  end

  def new
    @promotion = Promotion.new
  end

  def edit
  end

  def create
    @promotion = Promotion.new(promotion_params)

    respond_to do |format|
      if @promotion.save
        format.html { redirect_to @promotion, notice: 'Promotion was successfully created.' }
        format.json { render :show, status: :created, location: @promotion }
      else
        format.html { render :new }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @promotion.update(promotion_params)
        format.html { redirect_to @promotion, notice: 'Promotion was successfully updated.' }
        format.json { render :show, status: :ok, location: @promotion }
      else
        format.html { render :edit }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @promotion.destroy
    respond_to do |format|
      format.html { redirect_to promotions_url, notice: 'Promotion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def promotion_params
    params.require(:promotion).permit(:year, :calendar_url)
  end
end
