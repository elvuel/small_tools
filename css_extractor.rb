# encoding: utf-8
require 'css_parser'
require 'nokogiri'
require 'sass/css'
# TODO ancestors(name,id,class) match...
class CssExtractor
  include CssParser

  NO_CSS_NAMES = %w(head meta title link script style text #cdata-section comment)
  class << self
    # @return
    #   output sass/css file
    #  first args must like this =>  filename: "filename", output_sass: true/false
    def output!(*args)
      abort "any arguments must be Hash" unless args.inject(true) { |tf, arg| tf && (Hash === arg) }
      opts = args.shift
      filename = opts.delete(:filename).to_s
      abort "please specify the filename" if filename.empty?
      output_sass = opts.delete :output_sass
      selectors = args.inject({}) { |hash, arg| hash.merge arg  }
      filename << (output_sass ? ".sass" : ".css")
      rev = {}
      selectors.values.each do |value|
        keys = selectors.select { |k, v| v == value }.map { |k_v| k_v[0] }
        rev[keys.join(", ")] = value
      end
      css = rev.map do |k, v|
        <<-_CSS_
#{k} {
\t#{v.strip.split(";").join(";\n\t")};
}
        _CSS_
      end.join("\n")

      css = to_sass(css) if output_sass
      File.open(filename, "w") { |f| f.write css }
      puts "ok"
    end #output!

    def to_sass(css)
      begin
        Sass::CSS.new(css).render(:sass)
      rescue Sass::SyntaxError => e
        e.message
      end
    end #to_sass

  end # CssExtractor Self

  def initialize(css_parser, html, opts={})
    inst_css_parser css_parser
    @doc = Nokogiri::HTML html
    @used_css_selectors = {}
    get_all_css_selector!
    @opts = opts
    @typ = @opts[:typ] || true #拖油瓶
  end

  def call
    @all_node_names = []
    parse_css_from_node root_html_node
    @all_node_names.uniq!
    extract_css_snippets!
    if @opts.delete(:output)
      self.class.output!(@opts, @used_css_selectors)
    else
      @used_css_selectors
    end
  end

  private
  def inst_css_parser(css_parser)
    if String === css_parser
      @css_parser = CssParser::Parser.new
      @css_parser.load_file! css_parser
    else
      @css_parser = css_parser
    end
  end

  def get_all_css_selector!
    @all_css_selectors = []
    @css_parser.each_selector(:all) do |sel, desc, spec|
      @all_css_selectors << sel.strip
    end
    @all_css_selectors.compact!
    @all_css_selectors.uniq!
  end

  def extract_css_snippets!
    if @typ
      # update for nodes name
      @all_node_names.each do |nn|
        name_selectors = get_match_selectors(/\A#{nn}[\[|\:]/i)
        name_selectors.each do |sel|
          @used_css_selectors[sel.strip] = sel.strip
        end
      end

      m_ary = get_match_selectors(/\A[a-z]*\b[\[|\:].*[^\s]/i)
      m_ary.each do |sel|
        @used_css_selectors[sel.strip] = sel.strip
      end
    end

    # (@used_css_selectors.keys - @all_css_selectors).join("\n")
    # (@all_css_selectors - @used_css_selectors.keys).sort.join("\n")
    selectors_not_in_all = @used_css_selectors.keys - @all_css_selectors
    selectors_not_in_all.each { |not_sel| @used_css_selectors.delete not_sel }
    @used_css_selectors.each do |k,v|
      #@used_css_selectors[k] = @css_parser.find_by_selector(k).join
      css_defines = @css_parser.find_by_selector(k).flatten.join
      ary = css_defines.split(";").sort.collect { |item| item.strip }.compact
      ary.delete ""
      new_ary = ary.inject({}) do |h, prop|
        name, value = prop.split(":")
        value.strip!
        h[name] = value
        h
      end.map { |km,vm| "#{km}: #{vm}" }.sort

      @used_css_selectors[k] = new_ary.join(";")
    end
    @used_css_selectors
  end

  # deprecated
  def selectors_optimization!
    #=begin this is a bit slower than this below
    #rev1 = Hash.new{ |h,k| h[k]=[] }
    #@used_css_selectors.each{ |k,v| rev1[v] << k }
    #rev = {}
    #rev1.each { |k,v| rev[v.join(", ")] = k }
    #=end
    rev = {}
    @used_css_selectors.values.each do |value|
      keys = @used_css_selectors.select{ |k,v| v == value }.map { |k_v| k_v[0] }
      rev[keys.join(", ")] = value
    end
    @used_css_selectors = rev
  end

  def parse_css_from_node(node)
    node.children.each do |child|
      unless NO_CSS_NAMES.include? child.name
        get_node_css_selectors child
        @all_node_names << child.name
      end
      parse_css_from_node child unless child.children.empty?
    end
  end

  def get_node_css_selectors(node)
    id, classes, style = node.attr("id"), node.attr("class"), node.attr('style')
    id_selectors = get_selectors_by_id(id, node)
    classes_selectors = get_selectors_by_classes(classes, node)

    id_selectors = [] if id_selectors.nil?
    classes_selectors = [] if classes_selectors.nil?

    selectors = id_selectors.concat(classes_selectors)

    if id == nil && classes == nil
      selectors.concat(get_match_selectors(/.*\b#{node.name}\Z/))
    end
    selectors.concat(get_match_selectors(/\A#{node.name}[\[|\:]/))
    selectors = selectors.compact.uniq.flatten.collect { |item| item.strip }.uniq
    #selectors << node.name if selectors.empty?
    selectors << node.name # anyway go in
    selectors << "html"
    selectors << "body"
    selectors.each {|selector| @used_css_selectors[selector.strip] = selector.strip }
  end

  def get_match_selectors(pattern, selectors = nil)
    pattern = %r(#{pattern}) if String === pattern
    if selectors
      selectors.grep pattern
    else
      @all_css_selectors.grep pattern
    end
  end

  def get_node_ancestors(node, only_name = true)
    ancestors = node.ancestors.collect { |ancestor| ancestor }
    ancestors.pop if ancestors.last.name == "document"
    if only_name
      ancestors.collect!{ |item| item.name }
    else
      ancestors
    end
  end

  def get_selectors_by_id(id, node)
    return nil unless id
    id_matched_selectors = get_match_selectors(Regexp.new("##{Regexp.escape(id)}\\b"))
    return ["##{id}"] if id_matched_selectors.include? "##{id}"

    id_matched_selectors

    #ancestor_nodes = get_node_ancestors node, false
    #ancestor_nodes.unshift node
    #ancestor_nodes.collect! { |nd| { name: nd.name, id: nd.attr('id'), class: nd.attr('class') } }
    #name => /(\b#{v}\b).*#{Regexp.escape(id)}\b/
    #id => /(\b##{Regexp.escape(v)}\b).*#{Regexp.escape(id)}\b/
    #class => /\.(#{patten}).*#{Regexp.escape(id)}\b/

    #unless id_matched_selectors.empty?
    #  ancestor_nodes.inject([]) do |array, item|
    #    if item == node
    #      pattern = /\b#{item.name}##{Regexp.escape(id)}\b/i
    #      array << get_match_selectors(pattern, id_matched_selectors)
    #    else
    #      item_name = item.name
    #      pattern = /\b#{item_name}\b.*##{Regexp.escape(id)}\b/i
    #      array << get_match_selectors(pattern, id_matched_selectors)
    #
    #      item_id = item.attr("id")
    #      if item_id
    #        pattern = /##{Regexp.escape(item_id)}\b.*#{Regexp.escape(id)}\b/i
    #        array << get_match_selectors(pattern, id_matched_selectors)
    #      end
    #
    #      class_attr = item.attr("class")
    #      if class_attr
    #        ary = class_attr.split(/\s/)
    #        ary.delete ''
    #        unless ary.empty?
    #          pattern_classes = ary.collect { |c| Regexp.escape("#{c.strip}") }.join("|")
    #          pattern = /\.(#{pattern_classes}).*#{Regexp.escape(id)}\b/i
    #          array << get_match_selectors(pattern, id_matched_selectors)
    #        end
    #      end
    #
    #    end # if item
    #    array
    #  end.flatten.uniq
    #else
    #  []
    #end # unless

  end # get_selectors_by_id

  def get_selectors_by_classes(classes, node)
    return nil unless classes
    classes_ary = classes.split(/\s/)
    classes_ary.delete ''
    return [] if classes_ary.empty?
    cls_pattern = classes_ary.collect { |c| Regexp.escape("#{c.strip}") }.join("|")
    classes_matched_selectors = get_match_selectors(/\.(#{cls_pattern})\b/i)
    # just match
    tmp = classes_matched_selectors.dup.keep_if { |item| classes_ary.include?(item) }
    return classes_ary.collect { |sel| ".#{sel}" } if tmp.size == classes_ary.size

    classes_matched_selectors

    #name => /(\b#{v}\b).*\.(#{patten})\b/
    #id => /(\b##{Regexp.escape(v)}\b).*\.(#{patten})\b/
    ##class => /\.(#{patten_cls}).*\.(#{patten})\b/
    #
    #ancestor_nodes = get_node_ancestors node, false
    #ancestor_nodes.unshift node
    #
    #unless classes_matched_selectors.empty?
    #  obj = ancestor_nodes.inject([]) do |array, item|
    #    if item == node
    #      #pattern = /\b#{item.name}\.(#{cls_pattern})\b/i
    #      #puts pattern if classes == "content with-sidebar"
    #      #array << get_match_selectors(pattern, classes_matched_selectors)
    #      classes_ary.each do |cls|
    #        pattern = /\b#{item.name}\.#{Regexp.escape(cls)}\b/i
    #        tmp_ary = get_match_selectors(pattern, classes_matched_selectors)
    #        if tmp_ary.empty?
    #          pattern = /^\.#{Regexp.escape(cls)}\b/i
    #          array << get_match_selectors(pattern, classes_matched_selectors)
    #        else
    #          array << tmp_ary
    #        end
    #      end
    #
    #    else
    #      item_name = item.name
    #      pattern = /\b#{item_name}\b.*\.(#{cls_pattern})\b/i
    #      array << get_match_selectors(pattern, classes_matched_selectors)
    #
    #      item_id = item.attr("id")
    #      if item_id
    #        pattern = /##{Regexp.escape(item_id)}\b.*\.(#{cls_pattern})\b/i
    #
    #        if classes == "content with-sidebar"
    #          puts "an-id:"
    #          puts pattern
    #        end
    #        array << get_match_selectors(pattern, classes_matched_selectors)
    #      end
    #
    #      class_attr = item.attr("class")
    #      if class_attr
    #        tmp_ary = class_attr.split(/\s/)
    #        tmp_ary.delete ''
    #        unless tmp_ary.empty?
    #          pattern_classes = tmp_ary.collect { |c| Regexp.escape("#{c.strip}") }.join("|")
    #          pattern = /\.(#{pattern_classes}).*\.(#{cls_pattern})\b/i
    #          array << get_match_selectors(pattern, classes_matched_selectors)
    #        end
    #      end
    #
    #    end # if item
    #    array
    #  end.flatten.uniq
    #  if classes == "content with-sidebar"
    #    puts "*" * 20
    #    puts obj.inspect
    #    puts "_" * 20
    #  end
    #  obj
    #else
    #  []
    #end

  end

  def root_html_node
    @doc.children.each do |node|
      if node.class == Nokogiri::XML::Element
        return node
      end
    end
  end

end #CssExtractor
