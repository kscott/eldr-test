module Church
  class Transaction < ::Church::Base
    self.table_name = "transaction"
    belongs_to :campus
    has_many :splits, class_name: Church::TransactionDetail

    def self.by_campus(campus_ids)
      where(campus: campus_ids)
    end
  end
end
