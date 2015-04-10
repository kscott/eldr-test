module Church
  class CampusAccount < ::Church::Base
    self.table_name = "campus_transaction_detail_types"
    self.primary_keys = :campus_id, :transaction_detail_type_id
    has_many :choices
    belongs_to :campus
    belongs_to :account, foreign_key: :transaction_detail_type_id

    def self.active?(campus, account)
      where(campus: campus, account: account).size > 0
    end
  end
end
