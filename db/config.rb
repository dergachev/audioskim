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
      errors.add :filename, 'can only have the following extensions: ' + @@valid_extensions.join(", ")
    end
  end

  def self.createFromFile(filename, tempfile, requestIp)
    newUpload = Upload.create(:filename => Upload.ensureUniqueFilename(filename), :ip => requestIp, :transcription => nil )
    if newUpload.save
      File.open(newUpload.file_path, 'wb') do |f|
        f.write tempfile.read
      end
    end
    return newUpload.valid?
  end

  def self.ensureUniqueFilename(filename)
    return Time.now.to_i.to_s + "--" + filename
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
    return audio.to_text.to_yaml
  end

end
