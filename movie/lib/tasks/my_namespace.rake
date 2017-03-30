namespace :my_namespace do
  desc "TODO"
  task film: :environment do
  	require 'mechanize'
		
		Films = Class.new(ActiveRecord::Base)
		agent = Mechanize.new 
		page = agent.get('https://movie.douban.com/tag/2016?start=860&type=T')

		def add_to_database
			Films.create!(name: @name, category: @category, date: @date, rate: @rate)  # 将数据存入数据库
			rescue ActiveRecord::RecordNotFound   # 拦截异常 
				logger = Logger.new File.new('test.log') 
				logger.error("can't find the movie") # 日志记录  
				flash[:notice] = "error"				
		end

		50.times do 
			page.links_with(href: %r{/subject/}, text: %r{/^$|\s+/}).map do |link|
				current_page = link.click
				
				@name = current_page.search('title').inner_text.strip!.chomp!(' (豆瓣)')	 		# 爬取电影名
				@category = current_page.search("#info > span[property*=genre]").inner_text.scan(/.{2}|.+/).join('/')  	# 爬取类型，然后每隔两个字符添加'/'
				@date = current_page.search("#info > span[property*=initialReleaseDate]").inner_text 		# 爬取上映时间
				@rate = current_page.search("strong.ll").inner_text		# 爬取评分
				add_to_database
			end
			page = page.link_with(text: "后页>").click  # 翻页
		end
	end
end

		# class ApplicationController < ActionController::Base
  	# 		rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
 		# 		rescue Exception => msg  
 		# 		puts msg
  	# 		private

   #  		def record_not_found
   #    		render plain: "Not Found", status: 404
   #  		end
			# end