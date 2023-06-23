class CrudOperationsService
  extend Callbacks
  before_run %i[update show destroy edit], :set_variable
  before_run %i[new create], :new_instance

  attr_accessor :model, :params

  def initialize(model, params = {})
    @model = model
    @params = params
  end

  def index
    instance_variable_set("@#{model.to_s.downcase.pluralize}", model.all)
  end

  def create
    instance_variable_get("@#{model.to_s.downcase}").save
  rescue ActionController::ParameterMissing => e
    e
  end

  def update
    instance_variable_get("@#{model.to_s.downcase}").update(permitted_params)
  rescue ActionController::ParameterMissing => e
    e
  end

  def new
    instance_variable_get("@#{model.to_s.downcase}")
  end

  def edit
    instance_variable_get("@#{model.to_s.downcase}")
  end

  def show
    instance_variable_get("@#{model.to_s.downcase}")
  end

  def destroy
    instance_variable_get("@#{model.to_s.downcase}").destroy
  rescue StandardError => e
    e
  end

  private

  def new_instance
    instance_variable_set("@#{model.to_s.downcase}", model.new(permitted_params))
  end

  def set_variable
    instance_variable_set("@#{model.to_s.downcase}",
                          find_model_entity)
  end

  def find_model_entity
    model.find_by(id: params[:id] || params["#{model.to_s.downcase}_id".to_sym])
  end

  def permitted_params
    params.require(model.to_s.downcase.to_sym).permit(model_attributes) if valid_params?
  end

  def valid_params?
    params.is_a?(ActionController::Parameters) && params[model.to_s.downcase.to_sym].present?
  end

  def model_attributes
    string_to_sym_in_array(model.column_names.reject { |column| Constants::PREDEFINED_FIELDS.include?(column) })
  end

  def string_to_sym_in_array(arr)
    arr.map(&:to_sym)
  end
end
