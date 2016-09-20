require 'test_helper'

class ClientTest < Minitest::Test

  TEST_TICKETS = [
      { '_id' => '1',
        'name' => 'Test ticket 1',
        'description' => 'This is a test',
        'bin_id' => '1',
        'ticketType_id' => '1',
        'order' => 100},
      { '_id' => '2',
        'name' => 'Other test ticket 2',
        'description' => 'This is another test',
        'bin_id' => '1',
        'ticketType_id' => '1',
        'order' => 101}
  ]

  context "creating tickets" do
    should "succeed" do
      stub_ticket_types
      stub_bins
      stub_next_ticket_id
      stub_create_ticket

      client = Obeya::Client.new('company_id', 'username', 'password')
      client.create_ticket(
        'title',
        'description',
        format: 'text',
        ticket_type_name: 'bug',
        bin_name: /alpha/i
      )
    end
  end

  context "finding a ticket type" do
    should "succeed" do
      stub_ticket_types

      client = Obeya::Client.new('company_id', 'username', 'password')
      type = client.ticket_type('bug')
      assert_equal 'bug', type.name
      assert_equal 1, type.id
    end
  end

  context "loading ticket types" do
    should "succeed" do
      stub_ticket_types

      client = Obeya::Client.new('company_id', 'username', 'password')
      types = client.ticket_types
      assert_equal 2, types.size
      assert_equal 'bug', types[0].name
      assert_equal 1, types[0].id
      assert_equal 'feature', types[1].name
      assert_equal 2, types[1].id
    end
  end

  context "finding a bin" do
    should "succeed" do
      stub_bins

      client = Obeya::Client.new('company_id', 'username', 'password')
      type = client.bin('Alpha')
      assert_equal 'Alpha', type.name
      assert_equal 1, type.id
    end
  end

  context "loading bins" do
    should "succeed" do
      stub_bins

      client = Obeya::Client.new('company_id', 'username', 'password')
      bins = client.bins

      assert_equal 2, bins.size
      assert_equal 'Alpha', bins[0].name
      assert_equal 1, bins[0].id
      assert_equal 'Beta', bins[1].name
      assert_equal 2, bins[1].id
    end
  end

  context 'load tickets from bin' do
    setup do
      stub_bins
      stub_ticket_types
      stub_tickets_in_bin

      @client = Obeya::Client.new('company_id', 'username', 'password')
    end

    should 'succeed for all tickets' do
      all_tickets = @client.tickets_in_bin(1)

      assert_equal 2, all_tickets.size
      assert_equal 'Test ticket 1', all_tickets.first.title
      assert_equal 'This is a test', all_tickets.first.description
      assert_equal 'Alpha', all_tickets.first.bin.name
      assert_equal 'bug', all_tickets.first.ticket_type.name

      assert_equal 'Other test ticket 2', all_tickets.last.title
      assert_equal 'This is another test', all_tickets.last.description
      assert_equal 'Alpha', all_tickets.last.bin.name
      assert_equal 'bug', all_tickets.last.ticket_type.name
    end

    should 'succeed with matcher' do
      all_tickets = @client.matching_tickets_in_bin(1, /Other/)

      assert_equal 1, all_tickets.size
      assert_equal 'Other test ticket 2', all_tickets.last.title
      assert_equal 'This is another test', all_tickets.last.description
      assert_equal 'Alpha', all_tickets.last.bin.name
      assert_equal 'bug', all_tickets.last.ticket_type.name
    end

  end

  private

  def stub_bins
    stub_request(:get, "#{Obeya::Client::OBEYA_ROOT_URL}/rest/1/company_id/bins").to_return(
      status: 200,
      body: [{name: 'Alpha', _id: 1}, {name: 'Beta', _id: 2}]
    )
  end

  def stub_ticket_types
    stub_request(:get, "#{Obeya::Client::OBEYA_ROOT_URL}/rest/1/company_id/ticket-types").to_return(
      status: 200,
      body: [{name: 'bug', _id: 1}, {name: 'feature', _id: 2}]
    )
  end

  def stub_next_ticket_id
    stub_request(:get, "#{Obeya::Client::OBEYA_ROOT_URL}/rest/1/company_id/ids?amount=1").to_return(
      status: 200,
      body: [13]
    )
  end

  def stub_create_ticket
    request_body = "{\"name\":\"title\",\"description\":\"description\",\"rtformat\":\"text\",\"ticketType_id\":1,\"bin_id\":1}"
    stub_request(:post, "#{Obeya::Client::OBEYA_ROOT_URL}/rest/1/company_id/tickets/13").
      with(body: request_body).
      to_return(status: 200, body: "")
  end

  def stub_tickets_in_bin

    stub_request(:get, "#{Obeya::Client::OBEYA_ROOT_URL}/rest/1/company_id/tickets?bin_id=1").
        to_return(status: 200, body: TEST_TICKETS.to_json)
  end

end
