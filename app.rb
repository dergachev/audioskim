require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require File.dirname(__FILE__) + '/db/config.rb' 

configure do
	enable :inline_templates
	enable :sessions

	set :port, 9093
	set :bind, "0.0.0.0" # not default, contrary to docs
	
	set :files, File.join(File.dirname(__FILE__), 'public', 'files')
	set :uploaded_files, Dir.entries(settings.files) - ['.', '..']
end

get '/' do
  @uploads = Upload.all
  haml :upload
end

get '/transcribe/:upload' do
  upload = Upload[params[:upload].to_i] #params[:upload]]
  unless upload
    flash[:error] = "Invalid upload ID"
    redirect to '/'
  end
  return upload.transcribe
  flash[:notice] = "Transcribed upload " + upload.to_s
  redirect to '/'
end

post '/upload' do
  if params[:file] && Upload.createFromFile(params[:file][:filename], params[:file][:tempfile], request.ip) 
    flash[:notice] = "Upload successful"
  else
    flash[:error] = 'You have to choose a file'
  end

  redirect '/'
end

helpers do
  def transcription(upload)
    if upload.transcription
      return upload.transcription
    else 
      transcription_url = url('/transcribe/' + upload.id.to_s)
      return "<a href='#{transcription_url}'>Transcibe</a>"
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
            %a{:href => '/about'}About
          %li
            %a{:href => '/register'}Register
          %li
            %a{:href => '/contact'}Contact
        %p.navbar-text.pull-right
          %a{:href => '/login'} Login

@@ upload
%h2 Uploaded Files
%table.table
  %thead 
    %tr
      %th ID
      %th File
      %th IP
      %th Created
      %th Transcription
  %tbody
    - @uploads.each do |upload|
      %tr
        %td= upload.id
        %td
          %a(href="#{upload.file_url}") 
            = upload.file_url
        %td= upload.ip
        %td= upload.created
        %td= transcription(upload)

%form{:action=>"/upload",:method=>"post",:enctype=>"multipart/form-data"}
  %fieldset
    %legend Upload New File
    %input{:type=>"file",:name=>"file"}
    %span.help-block File to be transcribed, in WAV or MP3 or FLAC format.
    %input.btn{:type=>"submit",:value=>"Upload"}
