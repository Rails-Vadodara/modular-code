module CustomRouter
  REDIRECTION_CONFIG = YAML.load(File.open('config/action_redirection.yml'))['action_redirection']

  def redirection
    respond_to do |format|
      format.turbo_stream do
        eval("#{render_or_redirect}") if REDIRECTION_CONFIG[controller_name]['turbo_stream'].keys.include?(action_name)
      end
      format.html do
        eval("#{render_or_redirect}") if REDIRECTION_CONFIG[controller_name]['html'].keys.include?(action_name)
      end
      format.json { render :show, status: :created, location: @project }
    end
  end

  private

  def render_or_redirect
    singular?(variable_name) && instance_variable.errors.present? ? "render '#{errored_route}'" : "redirect_to '#{url}'"
  end

  def instance_variable
    instance_variable_get("@#{variable_name}")
  end

  def errored_route
    REDIRECTION_CONFIG.dig(controller_name, request.format.to_sym.to_s, 'fallbacks', action_name)
  end

  def action_route
    REDIRECTION_CONFIG.dig(controller_name, request.format.to_sym.to_s, action_name)
  end

  def url
    url_for(controller: controller_name, action: action_route, id: variable_id,
            only_path: true)
  end

  def singular?(variable_name)
    variable_name.pluralize != variable_name
  end

  def variable_id
    instance_variable&.id
  end
end
