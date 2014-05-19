class Profiles::PasswordsController < ApplicationController
  layout :determine_layout

  skip_before_filter :check_password_expiration, only: [:new, :create]

  before_filter :set_user
  before_filter :set_title
  before_filter :authorize_change_password!

  def new
  end

  def create
    new_password = params[:user][:password]
    new_password_confirmation = params[:user][:password_confirmation]

    result = @user.update_attributes(
      password: new_password,
      password_confirmation: new_password_confirmation
    )

    if result
      @user.update_attributes(password_expires_at: nil)
      redirect_to root_path, notice: t('general.notice.password_successfully_changed')
    else
      render :new
    end
  end

  def edit
  end

  def update
    password_attributes = params[:user].select do |key, value|
      %w(password password_confirmation).include?(key.to_s)
    end

    unless @user.valid_password?(params[:user][:current_password])
      redirect_to edit_profile_password_path, alert: I18n.t('you_must_provide_valid_password', scope: 'profiles.passwords.edit')
      return
    end

    if @user.update_attributes(password_attributes)
      flash[:notice] = I18n.t('password_was_successfully_updated', scope: 'profiles.passwords.edit')
      redirect_to new_user_session_path
    else
      render 'edit'
    end
  end

  def reset
    current_user.send_reset_password_instructions
    redirect_to edit_profile_password_path, notice: I18n.t('we_sent_you_an_email_with_reset_password_institutions', scope: 'profiles.passwords.edit')
  end

  private

  def set_user
    @user = current_user
  end

  def set_title
    @title = t('new_password', scope: 'profiles.passwords.new')
  end

  def determine_layout
    if [:new, :create].include?(action_name.to_sym)
      'navless'
    else
      'profile'
    end
  end

  def authorize_change_password!
    return render_404 if @user.ldap_user?
  end
end
