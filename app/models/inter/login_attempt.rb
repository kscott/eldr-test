module Inter
  class LoginAttempt < ::Inter::Base
    self.table_name = "login_attempt"

    def self.log(application, organization, individual, request)
      remote_ip = request["HTTP_X_FORWARDED_FOR"].to_s

      if remote_ip
        remote_split = remote_ip.split(/\s*,\s*/)

        remote_ip = if remote_split.size > 1
                      remote_split.slice(-2)
                    else
                      remote_split.first
                    end
      else
        remote_ip = request["action_dispatch.remote_ip"].to_s
      end

      remote_ip = "" if remote_ip.nil?

      remote_port = request["HTTP_X_FORWARDED_FOR_PORT"] ? request["HTTP_X_FORWARDED_FOR_PORT"] : ""
      success = !individual.new_record?
      individual_id = individual.id || 0
      user_agent = request['HTTP_USER_AGENT'] ? request['HTTP_USER_AGENT'][0, 120] : ""

      self.create(
        organization_id: organization.id,
        organization_name: organization.name[0, 50],
        source: application.name[0, 50],
        individual_id: individual_id,
        individual_name_first: individual.first_name[0, 50],
        individual_name_last: individual.last_name[0, 50],
        remote_addr: remote_ip[0, 20],
        remote_port: remote_port[0, 20],
        http_user_agent: user_agent,
        success: success
      )
    end
  end
end
