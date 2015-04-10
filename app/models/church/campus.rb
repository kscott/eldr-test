module Church
  class Campus < ::Church::Base
    self.table_name = 'campus'
    has_many :groups
    has_many :checkin_setups
    has_one :merchant
    has_and_belongs_to_many :accounts, join_table: :campus_transaction_detail_types, association_foreign_key: :transaction_detail_type_id
    default_scope -> { where.not(inactive: "1").order(:order_by) }
  end
end
