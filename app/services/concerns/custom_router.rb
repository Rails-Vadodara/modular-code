module CustomRouter
  REDIRECTION_CONFIG = YAML.load(File.open('config/action_redirection.yml'))

  def redirection
    controller_routes = REDIRECTION_CONFIG['action_redirection'][controller_name]
    return false unless controller_routes[action_name].present?

    url_for(controller: controller_name, action: controller_routes[action_name], id: instance_variable_get("@#{variable_name}")&.id,
            only_path: true)
  end
end
