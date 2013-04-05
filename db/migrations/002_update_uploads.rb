# run via "sequel -m db/migrations sqlite://db/audioskim.db"
# see http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
Sequel.migration do
  up do
    add_column :uploads, :description, String
    add_column :uploads, :duration, String
  end
  down do
    drop_column :uploads, :description
    drop_column :uploads, :duration
  end
end
