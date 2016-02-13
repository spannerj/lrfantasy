class Player
  include MongoMapper::Document

  key :code, String
  key :name, String
  key :team, String
  key :value, String
  key :position, String
  key :total, String
  key :stats, Array

  timestamps!
end