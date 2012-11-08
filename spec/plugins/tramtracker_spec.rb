require 'spec_helper'

describe "Agent99::Plugin::TramTracker" do
  describe "next_tram" do

    before(:each) do
      @plugin = IrcMachine::Plugin::TramTracker.new({})
      def @plugin.settings
        { "stops" => {
            "Outbound" => "2716",
            "Citybound" => "1716"
          },
          "url_pattern" => "http://tramtracker.com.au/?id=STOP_ID"
        }
      end
    end

    it "lists tram departure times" do
      citybound = File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample_tramtracker_1.html'))
      outbound = File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample_tramtracker_2.html'))

      RestClient.expects(:get).with('http://tramtracker.com.au/?id=1716').returns(citybound)
      RestClient.expects(:get).with('http://tramtracker.com.au/?id=2716').returns(outbound)

      @plugin.departure_times.should == <<-STRING.strip
Outbound: 109 in 4 mins
Outbound: 109 in 6 mins
Outbound: 109 in 18 mins
Citybound: 109 in 3 mins
Citybound: 109 in 7 mins
Citybound: 109 in 18 mins
      STRING
    end
  end
end
