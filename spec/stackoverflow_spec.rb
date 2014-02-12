require 'stackoverflow'

describe Stackoverflow do
  let(:client) { Stackoverflow::Client.new(nil) }

  it "fetches users by ids" do
    client.users_by_ids([178850]).each do |user|
      expect(user).to include('user_id', 'display_name', 'profile_image')
    end
  end

  it "fetches users associated accounts" do
    client.users_associated_accounts([178850]).each do |profile|
      expect(profile).to include('user_id', 'account_id', 'site_name')
    end
  end

  it "performs advanced question search" do
    client.advanced_search(tagged: %w[ruby javascript]).each do |profile|
      expect(profile).to include('owner', 'tags', 'question_id', 'is_answered')
    end
  end

  it "URL-encodes parameters" do
    expect(Stackoverflow::Client).to receive(:get) do |path, options|
      expect(path).to match /tags\/c%23/
      Struct.new(:code, :items).new(200, [])
    end

    client.users_top_answers([42], ['c#'])
  end
end
