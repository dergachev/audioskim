# run via "sequel -m db/migrations sqlite://db/audioskim.db"
# see http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
Sequel.migration do
  up do
    create_table(:uploads) do
      primary_key :id
      String :filename, :null=>false
      String :ip
      DateTime :created
      String :transcription
      index [:filename], :unique => true
    end
  end
  down do
    drop_table(:uploads)
  end
end
