class Service < ActiveRecord::Base
  has_many :labels
  has_many :service_columns
  has_many :experiments
  has_many :authorities

  def src_service
    Label.find_by src_service_id: id
  end

  def tgt_service
    Label.find_by tgt_service_id: id
  end
end
