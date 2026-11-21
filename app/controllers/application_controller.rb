# Base controller for the whole API. It centralises how domain errors raised by
# command/query handlers are translated into HTTP responses, so controllers in
# every bounded context stay thin and never rescue by themselves.
class ApplicationController < ActionController::API
  rescue_from Shared::InvalidInputError, with: :render_unprocessable
  rescue_from Shared::BusinessRuleError, with: :render_conflict
  rescue_from Shared::NotFoundError, with: :render_not_found

  private

  def render_unprocessable(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def render_conflict(error)
    render json: { error: error.message }, status: :conflict
  end

  def render_not_found(error)
    render json: { error: error.message }, status: :not_found
  end
end
