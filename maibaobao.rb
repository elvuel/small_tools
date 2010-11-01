require 'rubygems'
require 'nokogiri'
require 'http_request'

@bb = []

(1..41).to_a.each do |i|
  url = "http://www.mbaobao.com/goods/search.php?category_id=0&brand_id=0&sex_id=0&material_id=0&price=0&keyword=&order=time_down&page=#{i}"
  body = HttpRequest.get(url).body
  doc = Nokogiri::HTML(body)
  doc.xpath('//div[@class="product_box_bao"]').each do |item|
    img = item.css('div.pic img')[0].attr("src")
    link = item.css('div.text div.title a')[0]
    laoye = item.css("span.red")[0]
    href = link.attr("href")
    text = link.text
    market_price = item.css('s')[0].text
    mbb_price = item.css('span.price')[0].text
    if laoye
      ly = laoye.text
      @bb << { :img => img, :link => href, :title => text, :mp => market_price, :mbbp => mbb_price, :laoye => ly }
    end
  end
  sleep 0.1
  puts "#{i} ok."
end

@html =<<-EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"></meta>
	<title>mbb</title>
	<style type="text/css">
	body { background-color: #fff; color: #333; }

	body, p, ol, ul, td {
	  font-family: verdana, arial, helvetica, sans-serif;
	  font-size:   12px;
	  line-height: 18px;
	}
	
	#container {
		width: 900px;
		height: 100%;
		margin: 0 auto;
	}
	#item {
		float: left;
		width: 150px;
		height: 250px;
		border: 1px solid #333;
		padding: 10px;
		margin: 10px;
		text-align: center;
	}
	span {
		color: red;
	}
	img { border: 1px solid #987987; width: 80px; height: 80px; }
	</style>
</head>
</body>
<div id="container">

EOF
@bb.each do |bb|
  @html << "<div id='item'>\n\t"
  @html << "<span><img src='#{bb[:img]}'></span>\n\t"
  @html << "<h3><a href='#{bb[:link]}' target='_blank'>#{bb[:title]}</a></h3>\n\t"
  @html << "市场价：<s>#{bb[:mp]}</s><br />\n\t"
  @html << "麦包价：<span>#{bb[:mbbp]}</span><br />\n\t"
  color = "green"
  if bb[:laoye].index("老叶")
    color="red"
  end
  @html << "类型：<font color='#{color}'>#{bb[:laoye]}</font>\n\t"
  @html << "</div>\n\n"
end
@html << "</div>
</body>
</html>"
File.open("content_#{rand(10)}.html", "w+") do |f|
  f.write(@html)
end




