module JsonRequest
  extend ActiveSupport::Concern

  included do
    before { request.accept = 'application/json' }
  end
end
