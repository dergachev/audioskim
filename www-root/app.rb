# encoding: utf-8 
require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require File.dirname(__FILE__) + '/db/config.rb' 

configure do
	enable :inline_templates
	enable :sessions

	set :port, 9093
	set :bind, "0.0.0.0" # not default, contrary to docs
	
	set :public_dir, File.join(File.dirname(__FILE__), 'public')
	set :files, File.join(File.dirname(__FILE__), 'public', 'files')
	set :uploaded_files, Dir.entries(settings.files) - ['.', '..']
end

get '/' do
  @uploads = Upload.reverse_order(:id).all
  haml :upload
end

get '/transcribe/:upload' do
  upload = Upload[params[:upload].to_i] #params[:upload]]
  unless upload
    flash[:error] = "Invalid upload ID"
    redirect to '/'
  end
  transcription = upload.transcribe
  if transcription
    upload.transcription = transcription
    upload.save
    flash[:notice] = "Transcribed updated for upload ID " + upload.id.to_s
  else
    flash[:error] = "Unable to get transcription for upload ID " + upload.id.to_s
  end
  redirect to '/'
end

post '/upload' do
  unless params[:file]
    flash.now[:error] = "No file uploaded"
    return haml :upload_form
  end
  begin
    Upload.createFromFile(params[:file][:filename], params[:file][:tempfile], request.ip) 
    flash[:notice] = "Upload successful"
    redirect to '/'
  rescue Sequel::ValidationFailed => error
    # see http://sequel.rubyforge.org/rdoc/classes/Sequel/ValidationFailed.html
    flash.now[:error] = 'Validation error'
    error.errors.full_messages.each { |msg| flash.now[:error] = msg }
    return haml :upload_form
  end
end

get '/delete/:upload' do
  upload = Upload[params[:upload].to_i] #params[:upload]]
  upload.destroy
  flash[:notice] = "Deleted upload id" + upload.id.to_s
  redirect to '/'
end
  
post '/process_email' do
  filename = params['attachment-1'][:filename]
  tempfile = params['attachment-1'][:tempfile]
  ip = params[:From]
  subject = params[:subject]
  Upload.createFromFile(filename, tempfile, ip, subject)
  return
end

helpers do
  def upload_actions(upload)
    return { 
      'Transcribe' => url('/transcribe/' + upload.id.to_s),
      'Delete' => url('/delete/' + upload.id.to_s),
    }
  end
end

# ensures bootstrap-alert compatibility; from https://gist.github.com/mamantoha/3358074
module Sinatra
  module Flash
    module Style
      def styled_flash(key=:flash)
        return "" if flash(key).empty?
        id = (key == :flash ? "flash" : "flash_#{key}")
        close = '<a class="close" data-dismiss="alert" href="#">×</a>'
        messages = flash(key).collect {|message| "  <div class='alert alert-#{message[0]}'>#{close}\n #{message[1]}</div>\n"}
        "<div id='#{id}'>\n" + messages.join + "</div>"
      end
    end
  end
end
  
__END__

@@ layout
%html
  %head
    %link(rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/css/bootstrap.min.css")
    %link(rel="stylesheet" type="text/css" href="/css/styles.css")
    %script(src="//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript")
    %script(src="//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.0.3/bootstrap.min.js" type="text/javascript")
    %script(src="/js/script.js" type="text/javascript")
  %body
    %div= haml :navbar
    .container
      .content
        =styled_flash
        = yield

@@ navbar
.navbar.navbar-fixed-top
  .navbar-inner
    .container-fluid
      %a.btn.btn-navbar{ "data-toggle".to_sym => "collapse", "data-target".to_sym => ".nav-collapse"}
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar
      %a.brand{:href => '/'} Audioskim
      .nav-collapse
        %ul.nav
          %li
            %a{:href => '/'}Home
          %li
            %a{:href => '#/about'}About
          %li
            %a{:href => '#/register'}Register
          %li
            %a{:href => '#/contact'}Contact
        %p.navbar-text.pull-right
          %a{:href => '#/login'} Login

@@ upload_form
%form{:action=>"/upload",:method=>"post",:enctype=>"multipart/form-data"}
  %fieldset
    %legend Upload New File
    %input{:type=>"file",:name=>"file"}
    %span.help-block File to be transcribed, in WAV or MP3 or FLAC format.
    %input.btn{:type=>"submit",:value=>"Upload"}

@@ upload
%h2 Uploaded Files
%table.table
  %thead 
    %tr
      %th ID
      %th File
      %th IP
      %th Created
      %th Duration
      %th Description
      %th Transcription
      %th Actions
  %tbody
    - @uploads.each do |upload|
      %tr
        %td= upload.id
        %td
          %a(href="#{upload.file_url}")= upload.filename
        %td= upload.ip
        %td= upload.created && upload.created.strftime("%Y-%m-%d %H:%M")
        %td= upload.duration
        %td= upload.description
        %td= upload.transcription
        %td
          .dropdown
            %a.dropdown-toggle(href="#" data-toggle="dropdown") Actions
            %ul.dropdown-menu
              - upload_actions(upload).each do |name,url|
                %a(href="#{url}")= name
           
= haml :upload_form

