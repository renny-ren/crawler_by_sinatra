require 'mechanize'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'root',
  password: '123',
  database: 'crawler'
)
# class Films < ActiveRecord::Base;end
Films = Class.new(ActiveRecord::Base)

agent = Mechanize.new 
page = agent.get('https://movie.douban.com/tag/2016')

1.times do 
	page.links_with(href: %r{/subject/}, text: %r{/^$|\s+/}).map do |link|
		current_page = link.click
		name = current_page.search('title').inner_text.strip!.chomp!(' (豆瓣)')	 		# 爬取电影名
		category = current_page.search("#info > span[property*=genre]").inner_text.scan(/.{2}|.+/).join('/')  	# 爬取类型，然后每隔两个字符添加'/'
		date = current_page.search("#info > span[property*=initialReleaseDate]").inner_text 		# 爬取上映时间
		rate = current_page.search("strong.ll").inner_text		# 爬取评分
		Films.create!(name: name, category: category, date: date, rate: rate)  # 将数据存入数据库
	end
	page = page.link_with(text: "后页>").click  # 翻页
end


# rake

# exception log