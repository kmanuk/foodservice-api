require 'simplecov'
SimpleCov.start 'rails'

require 'database_cleaner'
require 'faker'
require 'airborne'
require 'factory_girl_rails'
require 'paperclip/matchers'
require 'sidekiq/testing/inline'
require 'webmock/rspec'

Sidekiq::Logging.logger = nil
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = 'log/rspec_failures.log'

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups


  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Paperclip::Shoulda::Matchers
  config.include FactoryGirl::Syntax::Methods
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:example, :focus) do
    fail "This example was committed with `:focus` and should not have been"
  end if ENV['CI']

  config.before(:each) do
    ActionMailer::Base.deliveries.clear

    allow(Drivers::Finder).to receive(:call).and_return(true)
    allow(Push::Send).to receive(:call).and_return(true)
    allow(Push::Generator).to receive(:call).and_return(true)
    allow(Orders::ChangeStatus).to receive(:call).and_return(InteractorStub.new)
    allow(Payments::Tokenization).to receive(:call).and_return(InteractorStub.new)
    allow(Payments::Response).to receive(:call).and_return(InteractorStub.new)
    allow(Payments::CancelAuthorization).to receive(:call).and_return(InteractorStub.new)
    allow(Orders::Cancel).to receive(:call).and_return(InteractorStub.new)
    allow(APN).to receive(:push).and_return(true)
    allow(DriverFinderWorker).to receive(:perform_async).and_return(true)
    allow(DriverFinderWorker).to receive(:perform_in).and_return(true)
    allow(DriverFinderWorker).to receive(:perform_at).and_return(true)
    allow(Sidekiq::Cron::Job).to receive(:create)

    stub_request(:get, /maps.googleapis.com\/maps\/api\/directions/).to_return(
        body: File.new(Rails.root.join('spec/support/fixtures/gmaps/directions.json'))
    )

    stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true').to_return(
        body: File.new(Rails.root.join('spec/support/fixtures/twitter/verify_credentials.json'))
    )

  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end

    I18n.locale = :en
  end

  config.before(:all) do
    Geocoder.configure(lookup: :test)

    Geocoder::Lookup::Test.set_default_stub(
        [
            {
                'latitude' => 40.7143528,
                'longitude' => -74.0059731
            }
        ]
    )
    Geocoder::Lookup::Test.add_stub(
        'Kiev, Khreshchatyk, Ukraine', [
        {
            'latitude' => 50.4501,
            'longitude' => 30.5234,
            'address' => 'Kiev, Ukraine',
            'country' => 'Ukraine'
        }
    ]
    )
    Geocoder::Lookup::Test.add_stub(
        'New York, NY, USA', [
        {
            'latitude' => 40.7143528,
            'longitude' => -74.0059731,
            'address' => 'New York, NY, USA',
            'country' => 'USA'
        }
    ]
    )
  end

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end
