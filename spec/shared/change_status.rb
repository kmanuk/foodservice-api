shared_examples 'seller change status to' do |status|
  it "#{status}" do
    result = Orders::ChangeStatus.call(user: seller, order: order)
    expect(result).to be_a_success
    expect(result.order.status).to eq(status)
  end
end

shared_examples 'driver change status to' do |status|
  it "#{status}" do
    result = Orders::ChangeStatus.call(user: driver, order: order)
    expect(result).to be_a_success
    expect(result.order.status).to eq(status)
  end
end

shared_examples 'buyer change status to' do |status|
  it "#{status}" do
    result = Orders::ChangeStatus.call(user: buyer, order: order)
    expect(result).to be_a_success
    expect(result.order.status).to eq(status)
  end
end
