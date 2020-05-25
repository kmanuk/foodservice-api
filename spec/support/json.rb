module Json
  def json
    let(:json) { JSON.parse(response.body) }
  end
end
