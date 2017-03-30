require 'sinatra'
require 'sinatra/flash'
require 'sinatra/basic_auth'
require 'active_record'
require 'will_paginate'  
require 'will_paginate/active_record'

use Rack::Session::Pool, :expire_after => 120  # 120秒无操作 session失效

configure do  
  ActiveRecord::Base.establish_connection(    # 链接数据库
    adapter:  'mysql2',
    host:     'localhost',
    username: 'root',
    password: '123',
    database: 'crawler'
  )
  User = Class.new(ActiveRecord::Base)
  Film = Class.new(ActiveRecord::Base)
  enable :sessions
end

authorize do |username, password|             # 设置管理员账户
  username == "admin" && password == "admin"
end
  
get '/' do 
    redirect '/login'   
end  
  
get '/login' do  
  erb :login
end  
  
post '/login' do 
  if params[:username] == 'admin' && params[:password] == 'admin'     # 验证是否管理员登陆
    session[:admin] = true
    redirect '/admin'
  end

  @user = User.find_by(username: params[:username])      # 在数据库中查找对应用户
  if @user && Digest::SHA256.hexdigest(params[:password] + @user.salt) == @user.hashed_pwd    # 验证用户名和密码
    session[:id] = @user.id
    redirect '/home'
  else
    flash[:error] = "Can't find this user!"
    redirect '/login'
  end  
end 

get '/signup' do
  erb :signup
end 

post '/signup' do
  @user_salt = Array.new(10){ rand(1024).to_s(36) }.join
  @user = User.create!(username: params[:username], hashed_pwd: Digest::SHA256.hexdigest(params[:password] + @user_salt), salt: @user_salt)
  session[:id] = @user.id
  redirect '/login'
end
  
get '/home' do   
  @user = User.find(session[:id]) 
  @films = Film.paginate(page: params[:page], per_page: 20)
  erb :home
end

get '/admin' do
  @films = Film.paginate(page: params[:page], per_page: 20)
  if session[:admin]
    erb :admin 
  else
    "没有权限"
  end
end

get '/sort_by_date' do
  @films = Film.paginate(page: params[:page], per_page: 20).order('date DESC')
  if session[:admin]
    erb :admin 
  else
    @user = User.find(session[:id])
    erb :home
  end
end

get '/sort_by_rate' do
  @films = Film.paginate(page: params[:page], per_page: 20).order('rate DESC')
  if session[:admin]
    erb :admin 
  else
    @user = User.find(session[:id])
    erb :home
  end
end
  
get '/logout' do  
  session.clear
  session[:admin] = false  
  redirect '/login'  
end 

protect do
  get '/destroy' do
    @film = Film.find(params[:id])
    @film.destroy   
    redirect '/admin'
  end
end
