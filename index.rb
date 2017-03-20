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
