class DatabaseManagement
  def self.configuration
    unless @config
      begin
        yaml = "config/database.yml"
        if File.exist?(yaml)
          require "erb"
          @config = YAML.load ERB.new(IO.read(yaml)).result
        end
      rescue Psych::SyntaxError => e
        raise "YAML syntax error occurred while parsing #{paths["config/database"].first}. " \
          "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
          "Error: #{e.message}"
      end
    end
    @config
  end

  def self.connect_to_church_database(organization_application, connection_type=:read, &block)
    if organization_application
      config = configuration["church_#{ENV["APP_ENV"]}"]
      host = if connection_type == :read
               organization_application.database_slave_server
             else
               organization_application.database_server
             end

      config = config.merge("database" => organization_application.database_name,
                            "host" => host)

      Church::Base.connection.disconnect! if Church::Base.connected?
      Church::Base.establish_connection(config)

      if block_given?
        begin
          result = block.call
        ensure
          Church::Base.connection.disconnect!
        end

        result
      end
    end
  end
end
