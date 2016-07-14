class LabelIndex < ActiveRecord::Base
  self.table_name = "label_indices"
  belongs_to :label
end
