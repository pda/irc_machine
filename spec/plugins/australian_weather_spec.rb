require 'spec_helper'

describe "Agent99::Plugin::AustralianWeather" do
  describe "report_weather" do

    before(:each) do
      @plugin = IrcMachine::Plugin::AustralianWeather.new({})
      def @plugin.settings
        { "url" => "http://www.bom.gov.au/vic/forecasts/melbourne.shtml" }
      end
    end

    it "outputs details from the BOMs weather report" do
      response = File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'sample_melbourne_forecast.html'))
      RestClient.stubs(:get).returns response

      @plugin.weather_report.should == <<-STRING
Today: 21, Shower or two.
Tomorrow: 18, Shower or two.
      STRING
    end
  end
end
