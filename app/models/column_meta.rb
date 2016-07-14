class ColumnMeta < ActiveRecord::Base
  self.table_name = "column_metas"
  belongs_to :service_column, foreign_key: "column_id"
end
