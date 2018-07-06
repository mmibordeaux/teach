class PromotionsController < ApplicationController
  load_and_authorize_resource
  before_action :load_promotion

  def index
    @promotions = Promotion.all
    @title = 'Promotions'
    @subtitle = 'Chaque année, de beaux étudiants bien frais'
    breadcrumb
  end

  def show
    @title = @promotion.to_s
    @subtitle = 'Répartition des heures du point de vue étudiant'
    @semesters = Semester.all
    breadcrumb
  end

  def sync
    @title = 'Synchronisation Google Calendar'
    Event.sync @promotion
    breadcrumb
    add_breadcrumb @title
  end

  def new
    @promotion = Promotion.new
    flash[:notice] = 'Synchronisation effectuée'
  end

  def edit
    @title = "#{@promotion} - Modifier"
    breadcrumb
    add_breadcrumb 'Modifier'
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

  protected

  def breadcrumb
    add_breadcrumb 'Promotions', :promotions_path
    add_breadcrumb @promotion.year, @promotion if @promotion
  end

  def load_promotion
    @promotion = Promotion.find params[:promotion_id] if params.include? :promotion_id
  end

  def promotion_params
    params.require(:promotion).permit(:year, :calendar_url)
  end
end
