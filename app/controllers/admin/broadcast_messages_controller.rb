class Admin::BroadcastMessagesController < Admin::ApplicationController
  before_filter :broadcast_messages

  def index
    @broadcast_message = BroadcastMessage.new
  end

  def create
    @broadcast_message = BroadcastMessage.new(params[:broadcast_message])

    if @broadcast_message.save
      redirect_to admin_broadcast_messages_path, notice: t('general.notice.was_successfully_created', model: BroadcastMessage.model_name.human)
    else
      render :index
    end
  end

  def destroy
    BroadcastMessage.find(params[:id]).destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render nothing: true }
    end
  end

  protected

  def broadcast_messages
    @broadcast_messages ||= BroadcastMessage.order("starts_at DESC").page(params[:page])
  end
end
