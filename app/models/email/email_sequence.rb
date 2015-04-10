module Email
  class EmailSequence < ::Email::Base
    self.table_name = "email_seq"

    def self.next_id
      begin
        next_id = ::Email::Base.connection.insert("UPDATE email_seq SET id = LAST_INSERT_ID(id + 1)")
      rescue Mysql2::Error => e
        logger.info "Connection lost to emaildb."
        raise
      rescue Exception => e
        retry
      end

      next_id
    end
  end
end
