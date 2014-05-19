class Admin::UsersController < Admin::ApplicationController
  before_filter :user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.filter(params[:filter])
    @users = @users.search(params[:name]) if params[:name].present?
    @users = @users.alphabetically.page(params[:page])
  end

  def show
    @projects = user.authorized_projects
  end

  def new
    @user = User.build_user
  end

  def edit
    user
  end

  def block
    if user.block
      redirect_to :back, alert: t('general.notice.successfully_blocked')
    else
      redirect_to :back, alert: t('general.notice.error_occurred_no_blocked')
    end
  end

  def unblock
    if user.activate
      redirect_to :back, alert: t('general.notice.successfully_unblocked')
    else
      redirect_to :back, alert: t('general.notice.error_occurred_not_unblocked')
    end
  end

  def create
    admin = params[:user].delete("admin")

    opts = {
      force_random_password: true,
      password_expires_at: Time.now
    }

    @user = User.build_user(params[:user].merge(opts), as: :admin)
    @user.admin = (admin && admin.to_i > 0)
    @user.created_by_id = current_user.id
    @user.generate_password
    @user.skip_confirmation!

    respond_to do |format|
      if @user.save
        format.html { redirect_to [:admin, @user], notice: t('general.notice.was_successfully_created', model: User.model_name.human) }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    admin = params[:user].delete("admin")

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if admin.present?
      user.admin = !admin.to_i.zero?
    end

    respond_to do |format|
      if user.update_attributes(params[:user], as: :admin)
        user.confirm!
        format.html { redirect_to [:admin, user], notice: t('general.notice.was_successfully_updated', model: User.model_name.human) }
        format.json { head :ok }
      else
        # restore username to keep form action url.
        user.username = params[:id]
        format.html { render "edit" }
        format.json { render json: user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # 1. Remove groups where user is the only owner
    user.solo_owned_groups.map(&:destroy)

    # 2. Remove user with all authored content including personal projects
    user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_path }
      format.json { head :ok }
    end
  end

  protected

  def user
    @user ||= User.find_by!(username: params[:id])
  end
end
