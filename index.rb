require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'yaml'

routes_info = YAML.load(File.read('meta_tag_content.yaml'))

routes_info.each do |route, info|
  get "/#{route}" do
    info = routes_info[[route, params[:direct_link]].join('/')] if params[:direct_link]
    @title = info['Title']
    @description = info['Description']
    erb :'index'
  end
end


get '/*' do
  @title = 'SWAYY | Targeted Influencer Marketing for Hotels & Restaurants'
  @description = 'Swayy is the world is first hotel and restaurant booking site for digital Influencers. Swayy helps Leisure Businesses increase sales and brand awareness through effective Influencer Marketing.'
  erb :'index'
end

