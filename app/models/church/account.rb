module Church
  class Account < ::Church::Base
    self.table_name = "transaction_detail_type"
    has_many :choices
    has_and_belongs_to_many :campuses, join_table: :campus_transaction_detail_types, foreign_key: :transaction_detail_type_id
    has_many :splits, class_name: Church::TransactionDetail, foreign_key: :type_id

    def giving_for_range(range_start, range_end = Time.now, campus = nil)
      transactions = (splits.joins(:transaction_record).where(transaction: {date: [range_start.beginning_of_day..range_end.end_of_day]}))
      transactions = transactions.where(transaction: {campus_id: Church::Campus.where(id: campus)}) unless campus.nil?
      transactions.sum(:amount) / 100.0
    end

    def self.find_all_by_campus_and_range(campuses, range)
      accounts = Church::Account.all.to_a

      accounts_in_campus = joins("INNER JOIN campus_transaction_detail_types ON transaction_detail_type.id = campus_transaction_detail_types.transaction_detail_type_id")
      unless campuses.empty?
        accounts_in_campus = accounts_in_campus.where('campus_transaction_detail_types.campus_id IN (:campuses)', campuses: campuses)
      end

      accounts_in_transaction = joins("INNER JOIN transaction_detail ON transaction_detail_type.id = transaction_detail.type_id")
      accounts_in_transaction = accounts_in_transaction.joins("INNER JOIN transaction ON transaction_detail.transaction_id = transaction.id")
      if range
        accounts_in_transaction = accounts_in_transaction.where("(transaction.date BETWEEN :start AND :end) AND transaction.campus_id IN (:campuses)", start: range[:start], end: range[:end], campuses: campuses)
      end

      ending_accounts = accounts_in_campus.to_a + accounts_in_transaction.to_a

      parent_ids = ending_accounts.map(&:parent_id).select { |parent_id| parent_id != 0 }


      until parent_ids.empty?
        new_parent_ids = []
        parent_ids.each do |parent_id|
          acc = accounts.find { |account| account.id == parent_id }

          ending_accounts << acc unless acc.nil?
          new_parent_ids << acc.parent_id unless acc.nil? || acc.parent_id == 0
        end

        parent_ids = new_parent_ids
      end

      ending_accounts.uniq { |account| account.id }.sort_by { |account| account.order_by }
    end
  end
end
