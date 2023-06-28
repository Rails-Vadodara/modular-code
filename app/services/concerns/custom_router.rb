module CustomRouter
  REDIRECTION_CONFIG = YAML.load(File.open('config/action_redirection.yml'))['action_redirection']

  def redirection
    respond_to do |format|
      format.html { redirect_to url if singular?(variable_name) }
      format.json { render :show, status: :created, location: @project }
    end
  end

  private

  def redirections
    redirect_to url if action_route.present?
  end

  def instance_variable
    instance_variable_get("@#{variable_name}")
  end

  def fallback_check
    singular?(variable_name) && instance_variable.errors.present? ? errored_route : action_route
  end

  def errored_route
    REDIRECTION_CONFIG[controller_name]['fallbacks'][action_name]
  end

  def action_route
    REDIRECTION_CONFIG[controller_name][action_name]
  end

  def url
    url_for(controller: controller_name, action: fallback_check, id: variable_id,
            only_path: true)
  end

  def singular?(variable_name)
    variable_name.pluralize != variable_name
  end

  def variable_id
    instance_variable&.id
  end
end
