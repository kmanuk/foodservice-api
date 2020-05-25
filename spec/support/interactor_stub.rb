class InteractorStub
  attr_accessor :failed, :errors, :options

  def initialize params = {}
    @failed  = params[:failed] || false
    @errors  = params[:errors]
    @options = params[:options] || {}
  end

  def success?
    !failed
  end

  def failure?
    failed
  end

  def method_missing method, *args, &block
    if options[method]
      options[method]
    else
      super method, *args, &block
    end
  end
end
