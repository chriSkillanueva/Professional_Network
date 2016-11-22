class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    if session[:user_id]
      User.find(session[:user_id])
    end
  end

  def require_login
    if session[:user_id] == nil
      flash[:not_logged_in] = 'Must Be Logged In'
      redirect_to '/'
    end
  end

  def require_correct_user
    user = User.find(params[:id])
    if current_user != user
      flash[:error] = "You Can't Do That"
      redirect_to "/profile"
    end
  end

end
