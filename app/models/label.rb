class Label < ActiveRecord::Base
  belongs_to :service
  has_many :label_metas
  has_many :label_index

end
