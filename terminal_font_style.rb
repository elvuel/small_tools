module Elvuel
  module TerminalFontStyle
    @@terminal_font_style = {
      # attributes
    	:attributes => {
    	  :bold       =>    "1",
      	:dim        =>    "2",
      	:underline  =>    "4",
      	:blink      =>    "5",
      	:reverse    =>    "7",
      	:concealed  =>    "8",
      	:normal     =>    "0",
      	:default    =>    "0"
    	},
    	# foreground colors
    	:foregrounds => {
      	:black      =>    "30", 
      	:red        =>    "31",
      	:green      =>    "32",
      	:yellow     =>    "33",
      	:blue       =>    "34",
      	:magenta    =>    "35",
      	:cyan       =>    "36",
      	:white      =>    "37"
    	},
    	# background colors
    	:backgrounds => {
      	:black   =>    "40", 
      	:red     =>    "41",
      	:green   =>    "42",
      	:yellow  =>    "43",
      	:blue    =>    "44",
      	:magenta =>    "45",
      	:cyan    =>    "46",
      	:white   =>    "47"
    	}
    }
    
    @@index_style_key = { 0 => :attributes, 1 => :foregrounds, 2 => :backgrounds }
    @@index_style_default = { 0 => :default, 1 => :black, 2 => :white }
    
    def self.method_missing(name, *args, &block)
      result = []
      styles = name.to_s.split("_")
      raise "Terminal font style method format: normal_white_black" if styles.length > 3

      auto_reset = true
      auto_merge = true
      msg = ""
      if args.length == 1
        msg = args.first.to_s
      elsif args.length > 1
        msg = args.shift.to_s
        if args.first.kind_of?(Hash)
          auto_reset = (args.first[:reset].to_s == "true") ? true : false
          auto_merge = (args.first[:merge].to_s == "true") ? true : false
        else
          auto_reset = (args.first.to_s == "true") ? true : false
          auto_merge = (args.last.to_s == "true") ? true : false
        end
      else
        return ""
      end
      
      return msg if RUBY_PLATFORM =~ /(:?mswin|mingw)/

      styles.each_with_index do |style, index|
        h_key = @@index_style_key[index]
        value = @@terminal_font_style[h_key][style.to_s.to_sym].nil? ? @@terminal_font_style[h_key][@@index_style_default[index]] : @@terminal_font_style[h_key][style.to_s.to_sym]
        result << value
      end
      
      style_str = ""
      
      if auto_merge
        style_str = "\033[#{result.join(";")}m"
      else
        style_str = result.collect { |item| "\033[#{item}m" }.join("")
      end
      
      if auto_reset
        style_str + msg + self.normal("", false, false)
      else
        style_str + msg
      end
    end

  end
end

include Elvuel

puts TerminalFontStyle.normal_white_black("-info-")
puts TerminalFontStyle.normal_white_black("-info-", true, true)
puts TerminalFontStyle.normal_white_black("-info-", true, false)
puts TerminalFontStyle.normal_white_black("-info-", false, true)
puts TerminalFontStyle.normal_white_black("-info-", false, false)
puts "\n"
puts TerminalFontStyle.normal_white_black("-info-")
puts TerminalFontStyle.normal_white_black("-info-", :reset => true, :merge => true)
puts TerminalFontStyle.normal_white_black("-info-", :reset => true, :merge => false)
puts TerminalFontStyle.normal_white_black("-info-", :reset => false, :merge => true)
puts TerminalFontStyle.normal_white_black("-info-", :reset => false, :merge => false)
puts TerminalFontStyle.default("")