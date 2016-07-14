class LabelMetum < ActiveRecord::Base
  self.table_name = "label_metas"
  belongs_to :label
end
