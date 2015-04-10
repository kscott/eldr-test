module Church
  class TransactionDetail < ::Church::Base
    self.table_name = "transaction_detail"
    belongs_to :transaction_record, class_name: Church::Transaction, foreign_key: :transaction_id
    belongs_to :account, foreign_key: :type_id
    delegate :campus, to: :transaction_record

    def self.by_campus(campus_ids)
      joins(:transaction_record).merge(Church::Transaction.by_campus(campus_ids))
    end
  end
end
