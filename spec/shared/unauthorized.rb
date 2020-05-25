shared_examples 'render 401' do |method, actions, options|
  context "for #{method.upcase}" do
    Array.wrap(actions).each do |action|
      it "##{action}" do
        send(method, action, options)
        expect(response).to have_http_status(401)
      end
    end
  end
end
