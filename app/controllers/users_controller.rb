class UsersController < ApplicationController
  before_action :require_login, except: [:index, :register, :login]
  before_action :require_correct_user, only: [:edit, :update, :destroy]

  def index
  end

  def register
    user = User.new(name: params[:name], email: params[:email], password: params[:password], password_confirmation: params[:confirm], description: params[:description])

    if user.save
      session[:user_id] = user.id
      redirect_to "/profile"

    else
      errors = user.errors
      flash[:name_error] = errors['name'].join(", ").capitalize
      flash[:email_error] = errors['email'].join(", ").capitalize
      flash[:password_error] = errors['password'].join(", ").capitalize
      flash[:confirm_error] = errors['password_confirmation'].join(", ").capitalize
      flash[:description_error] = errors['description'].join(", ").capitalize

      redirect_to '/'
    end

  end

  def login
    user = User.find_by email: params[:email]

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to "/profile"

    else
      flash[:login_error] = "Invalid Email/Password Combination"
      redirect_to "/"
    end
  end

  def profile
    @user = User.find(session[:user_id])
    #users that sent a request to the current user
    @invites = Invitation.where(["invite_id = ?", session[:user_id]])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    user.name = params[:name]
    user.email = params[:email]
    user.description = params[:description]

    if user.save
      redirect_to "/profile"

    else
      errors = user.errors
      flash[:name_error] = errors['name'].join(", ").capitalize
      flash[:email_error] = errors['email'].join(", ").capitalize
      flash[:description_error] = errors['description'].join(", ").capitalize
      redirect_to "/edit/#{params[:id]}"
    end
  end

  def show
    @user = User.find(session[:user_id])
    @friend = User.find(params[:id])

    if @user == @friend
      flash[:error] = "You Can't Do That"
      redirect_to '/profile'
    end
  end

  def all
    @user = User.find(session[:user_id])

    #to display users who aren't connected with current user & users who have no invitations pending with the current user
    all_users = User.where("id != ?", session[:user_id])
    all_friends = Friendship.where(["user_id = ?", session[:user_id]]).pluck('friend_id')
    sent_invite = Invitation.where(["user_id = ?", session[:user_id]]).pluck('invite_id')
    pending_invite = Invitation.where(["invite_id = ?", session[:user_id]]).pluck('user_id')
    @connect_with = []

    all_users.each do |x|
      unless all_friends.include?(x.id) || sent_invite.include?(x.id) || pending_invite.include?(x.id)
        @connect_with.append(x)
      end
    end

    #users that sent a request to the current user
    @accept = Invitation.where(["invite_id = ?", session[:user_id]])

    #users that were sent a request from the current user
    @sent = Invitation.where(["user_id = ?", session[:user_id]])

  end

  def invite
    #create invitation from user sending to user recieving
    Invitation.create(user_id: params[:user_id], invite_id: params[:invite_id])
    redirect_to '/users'
  end

  def network
    #when a user accepts a request, invitations(can be in either direction) between the two are destroyed
    Invitation.where(user_id: params[:friend_id], invite_id: params[:user_id]).destroy_all
    Invitation.where(user_id: params[:user_id], invite_id: params[:friend_id]).destroy_all

    #then, the friendship is created in both directions
    Friendship.create(user_id: params[:user_id], friend_id: params[:friend_id])
    Friendship.create(user_id: params[:friend_id], friend_id: params[:user_id])

    redirect_to '/profile'
  end

  def ignore
    #destroy the pending request
    Invitation.where(user_id: params[:user_id], invite_id: params[:invite_id]).destroy_all

    redirect_to '/profile'
  end

  def disconnect
    #destroy Friendship in both directions
    Friendship.where(user_id: params[:user_id], friend_id: params[:friend_id]).destroy_all
    Friendship.where(user_id: params[:friend_id], friend_id: params[:user_id]).destroy_all
    redirect_to '/profile'
  end

  def destroy
    user = User.find(params[:id]).destroy
    session.clear
    redirect_to '/'
  end

  def logout
    session.clear
    redirect_to "/"
  end
end
