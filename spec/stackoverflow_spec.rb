require 'stackoverflow'

describe Stackoverflow do
  let(:client) { Stackoverflow::Client.new(nil) }

  it "fetches users by ids" do
    response = client.users_by_ids([178850]).first
    expect(response).to include('user_id', 'display_name', 'profile_image')
  end
end
