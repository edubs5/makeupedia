require 'net/http'

module WikisHelper
  def build_the_search(params)
    params[:search_page].gsub(" ","_")
  end

  def build_the_json(params)
    title_uri = "http://en.wikipedia.org/" + build_the_search(params)
    @data = {
              uri: (params[:search_page].empty? ? URI.parse("http://en.wikipedia.org/wiki/Internet") : URI.parse(title_uri)),
              ## TO DO: Trap below for empty? Or should this be an error?
              search_text: (params[:search].nil? ? "" : Regexp.new(params[:search], Regexp::IGNORECASE)),
              replace_text: (params[:replace].nil? ? "" : params[:replace])
            }
    build_the_page
  end

  def build_the_page
    content = Net::HTTP.get_response(@data[:uri]).body.force_encoding('UTF-8')
    object_to_break = Nokogiri::HTML(content)
    break_the_object(object_to_break)
    add_our_stuff_to(object_to_break)
    { content: object_to_break.serialize(:encoding => 'UTF-8') }
  end

  def add_our_stuff_to(nokogiri_object)
    # jquery-mobile-css
    head = nokogiri_object.at_css("head")
    link = Nokogiri::XML::Node.new "link", nokogiri_object
    link['rel'] = "stylesheet"
    #link['href'] = "http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.css"
    link['href'] = "/public/jquery.mobile.custom.structure.min.css"
    head.children.last.add_next_sibling(link)

    head = nokogiri_object.at_css("head")
    link = Nokogiri::XML::Node.new "link", nokogiri_object
    link['rel'] = "stylesheet"
    link['href'] = "/public/jquery.mobile.custom.theme.min.css"
    head.children.last.add_next_sibling(link)

    # jquery-mobile-js
    script = Nokogiri::XML::Node.new "script", nokogiri_object
    #script['src'] = "http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.js"
    script['src'] = "/public/jquery.mobile.custom.min.js"
    head.children.last.add_next_sibling(script)

    # body
    body = nokogiri_object.at_css("body")
    form_div = Nokogiri::XML::Node.new "div", nokogiri_object
    form_div['id'] = "bottom-menu"
    style = "background-color:rgba(0,0,0,0.4);
            border-top-left-radius:5px;
            border-top-right-radius:5px;
            width:80%;
            height:35%;
            position:fixed;
            left:50%;
            bottom: 0px;
            margin-left:-40%;
            overflow: hidden;"
    form_div['style'] = style

    # # iframe
    # iframe = Nokogiri::XML::Node.new "iframe", nokogiri_object
    # iframe['src'] = "/frames"
    # iframe['style'] = "width:90%; height:90%;  allowtransparency='true'; display:block;"

    # # form
    wiki_form = Nokogiri::XML::Node.new "form", nokogiri_object
    wiki_form['accept-charset'] = "UTF-8"
    wiki_form['action'] = "/wikis"
    wiki_form['class'] = "main-form"
    wiki_form['data-remote'] = "true"
    wiki_form['method'] = "post"

    # first form div
    div_one = Nokogiri::XML::Node.new "div", nokogiri_object
    div_one['style'] = "margin:0;padding:0;display:inline"

    # input_one on div_one
    input_one = Nokogiri::XML::Node.new "input", nokogiri_object
    input_one['name'] = "utf8"
    input_one['type'] = "hidden"
    input_one['value'] = "U+2714"

    # input_two on div_one
    input_two = Nokogiri::XML::Node.new "input", nokogiri_object
    input_two['name'] = "authenticity_token"
    input_two['type'] = "hidden"
    input_two['value'] = form_authenticity_token

    # basic input, on form
    input_basic = Nokogiri::XML::Node.new "input", nokogiri_object
    input_basic['type'] = "text"
    input_basic['name'] = "text-basic"
    input_basic['id'] = "text-basic"
    input_basic['value'] = ""

    # add them in, last first
    div_one.add_child(input_one)
    div_one.add_child(input_two)
    form_div.add_child(div_one)
    form_div.add_child(input_basic)
    form_div.add_child(wiki_form)

    #form_div.add_child(iframe)
    body.children.last.add_next_sibling(form_div)

# #<form accept-charset="UTF-8" action="/wikis" class="main-form" data-remote="true" method="post">
#     <div style="margin:0;padding:0;display:inline">
#       <input name="utf8" type="hidden" value="✓">
#       <input name="authenticity_token" type="hidden" value="ne+CtNs/sStCk4p5uGHjaQO53wu4RVpMjfStaIgIVXw=">
#     </div>
#     <input type="text" name="text-basic" id="text-basic" value="">
# #</form>

  end

  def break_the_object(node)
    return node.content = node.content.to_s.gsub(@data[:search_text],@data[:replace_text]) if node.children.empty? && node.text?
    node.children.each{|e| break_the_object(e)} unless node.children.empty?
  end
end

__END__

# $('body').append("<div id='bottom-menu' style='padding:5px;position:fixed;bottom:0;width:50%;margin-left:auto;margin-right:auto;height:50px;z-index:100;background-color:yellow'><h1>HELLO</h1></div>")
# $('bottom-menu').slideDown
# $('bottom-menu').slideUp

# outerDiv = "<div id='outer' style='bottom: 0;height: 30px;margin: 0 auto;position: fixed;width: 100%'></div>"
# innerDiv = "<div id='inner' style='background: none repeat scroll 0 0 #FF0000;bottom: 0;font-size: 10px;height: 30px;overflow: hidden; margin: 0 auto;max-width: 1000px;width: 960px'>Yo</div>"
# $('body').append(outerDiv)
# $('body').append(innerDiv)

formDiv = "<div id='bottom-menu' style='background-color:blue; width:50%; height:45%; position:fixed; left:50%; bottom: 0px; margin-left:-25%;'></div>";
$('body').append(formDiv);
$('#bottom-menu').slideDown();
$('#bottom-menu').slideUp();

require 'net/http'
require 'nokogiri'
content = Net::HTTP.get_response(URI.parse("http://en.wikipedia.org/wiki/Internet")).body.force_encoding('UTF-8')

def break_the_object(node)
  return node.content = node.content.to_s.gsub("was","wasn't") if node.children.empty? && node.text?
  node.children.each{|e| break_the_object(e)} unless node.children.empty?
end

head = object_to_break.at_css("head")
link = Nokogiri::XML::Node.new "link", object_to_break
link['rel'] = 'stylesheet'
link['href'] = "http://code.jquery.com/mobile/1.3.2/jquery.mobile-1.3.2.min.css"
head.children.last.add_next_sibling(link)