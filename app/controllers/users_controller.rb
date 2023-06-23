class UsersController < ApplicationController
  include CustomRouter

  %w[show edit create update destroy index new].each do |no_params_method|
    define_method no_params_method do
      instance_variable_set("@#{variable_name}", CrudOperationsService.new(User, params).send(no_params_method))
      respond_to do |format|
        format.html { redirect_to redirection if redirection }
        format.json { render :show, status: :created, location: @project }
      end
    end
  end

  private

  def variable_name
    Constants::MULTIPLE_ENTITY.include?(action_name) ? controller_name : controller_name.singularize
  end
end
