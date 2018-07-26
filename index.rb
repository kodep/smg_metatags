require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'yaml'

configure do
  set :protection, :except => :frame_options
end

routes_info = YAML.load(File.read('meta_tag_content.yaml'))

def find_hashed_js
  js_filename = `find /home/deployer/smg_frontend/js -name "appcomponents*.js" | sed 's#.*/##'`
  js_filename = `find /home/ubuntu/html/js -name "appcomponents*.js" | sed 's#.*/##'` if js_filename.strip == ''
  puts "JS_FILENAME: #{js_filename}"
  js_filename = 'appcomponents.js' if js_filename.strip == ''
  js_filename
end

routes_info.each do |route, info|
  get "/#{route}" do
    info = routes_info[[route, params[:direct_link]].join('/')] if params[:direct_link]
    @title = info['Title']
    @description = info['Description']
    @js_filename = find_hashed_js
    erb :'index'
  end
end

get "/support" do
  @js_filename = find_hashed_js
  case params[:direct_link]
    when "general"
      @title = routes_info["support/general"]["Title"]
      @description = routes_info["support/general"]["Description"]
      erb :'index'
    when "publishers"
      @title = routes_info["support/publishers"]["Title"]
      @description = routes_info["support/publishers"]["Description"]
      erb :'index'
    when "influencers"
      @title = routes_info["support/influencers"]["Title"]
      @description = routes_info["support/influencers"]["Description"]
      erb :'index'
  end
end

get '/*' do
  @title = 'SWAYY | Targeted Influencer Marketing for Hotels & Restaurants'
  @description = "Swayy is the world's first hotel and restaurant booking site for digital Influencers. Swayy helps Leisure Businesses increase sales and brand awareness through effective Influencer Marketing."
  @js_filename = find_hashed_js
  erb :'index'
end
