custom_methods = {}

Api::Base.routes.each do |route|
  method_segments = []
  parameters = []
  path_segments = route.route_path[1..-1].split('/')
  url_template = route.route_path.gsub(/\(\.:format\)/, '')

  path_segments.each do |path_segment|
    path_segment.gsub!(/\(\.:format\)/, '')
    path_segment.gsub!(/\./, '_')

    case path_segment
    when /^:(.+)/ # Variable in the regular expression
      parameters << path_segment
    when /^(\w+)/ # Segment of the method name
      method_segments << path_segment.singularize
    end
  end

  path_method_name = if (method_segments.size > 1)
    "#{method_segments.join('_').pluralize}_path"
  else
    "#{method_segments.join('_')}_path"
  end

  if custom_methods[path_method_name].nil?
    custom_methods[path_method_name] = []
  end

  custom_methods[path_method_name] << {
    parameters: parameters,
    url_template: url_template
  }
  custom_methods[path_method_name].uniq!
end

custom_methods.each do |method_name, settings|
  define_method(method_name) do |*args|
    settings.each do |setting|
      if args.size == setting[:parameters].size
        path = setting[:url_template].dup

        setting[:parameters].each_index do |parameter_index|
          parameter = setting[:parameters][parameter_index][1..-1]
          parameter_value = ""
          if args[parameter_index].respond_to?(parameter)
            parameter_value = args[parameter_index].send(parameter)
          else
            parameter_value = args[parameter_index]
          end

          path.gsub!(/#{setting[:parameters][parameter_index]}/, parameter_value.to_s)
        end 

        return path
      end
    end

    raise "#{method_name} with #{args.size} #{'parameter'.pluralize(args.size)} not found"
  end
end
