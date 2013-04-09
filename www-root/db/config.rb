require 'sequel'
require 'speech' #speech2text gem

set :database, Sequel.connect('sqlite://db/audioskim.db')
class Upload < Sequel::Model
  plugin :timestamps, :create => :created
  @@valid_extensions = ['.wav', '.mp3', '.flac' ]
  @@upload_path = ['public', 'files']

  def validate
    super
    # TODO: validate file uploaded

    unless @@valid_extensions.include? File.extname(filename)
      errors.add :file, 'can only have the following extensions: ' + @@valid_extensions.join(", ")
    end
  end

  def self.createFromFile(filename, tempfile, requestIp, description = "")
    newUpload = Upload.create(
      :filename => filename, 
      :ip => requestIp, 
      :transcription => nil, 
      :duration => Upload.getDuration(tempfile), 
      :description => description)
    if newUpload.save
      File.open(newUpload.file_path, 'wb') do |f|
        f.write tempfile.read
      end
    end
    return newUpload.valid?
  end

  def self.getDuration(file)
    begin 
      return Speech::AudioInspector.new(file.path).duration
    rescue RuntimeError => e
    end
  end

  def file_path
    return File.join(@@upload_path, self.filename)
  end

  def file_url
    return File.join(@@upload_path[1..-1], self.filename)
  end

  def transcribe
    audio = Speech::AudioToText.new(self.file_path, :verbose => true)
    #return audio.to_yaml
    return audio.to_text(7)
  end

  def before_create
    self.filename = Time.now.to_i.to_s + "--" + self.filename
    super
  end

  def before_destroy
    if File.exists? self.file_path
      File.delete(self.file_path)
    end
    super
  end

end
