class Promotions::EventsController < PromotionsController
  def index
      @title = 'EDT: événements bruts'
      @subtitle = @promotion.to_s
      breadcrumb
      add_breadcrumb @title
  end

  def imported
    @title = 'EDT: événements importés'
    @subtitle = @promotion.to_s
    breadcrumb
    add_breadcrumb @title
  end

  def sync
    @promotion.sync_events
    redirect_to promotion_events_imported_path(@promotion), notice: 'En cours de synchronisation'
  end
end
