class ServiceColumn < ActiveRecord::Base
  belongs_to :service
  has_many :column_metas, foreign_key: "column_id"
end
