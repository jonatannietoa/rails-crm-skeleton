# Liveness probe. Kept outside the bounded contexts on purpose.
class HealthController < ApplicationController
  def show
    render json: { status: "ok" }
  end
end
