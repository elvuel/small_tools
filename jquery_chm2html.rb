# == Description
# Change terminal title.
# == Author
# elvuel<elvuel@gmail.com>
#
system("wget http://jquery-api-zh-cn.googlecode.com/files/jQueryAPI-100214.zip")
system("unzip jQueryAPI-100214.zip")
system("mkdir jQueryAPI")
system("extract_chmLib jQueryAPI-100214.chm jQueryAPI/")
system("mv jQueryAPI/cheatsheet.html jQueryAPI/index.html")
system("rm jQueryAPI-100214.*")
puts "ok"