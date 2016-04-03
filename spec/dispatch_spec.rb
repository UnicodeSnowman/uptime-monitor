require 'dispatch/dispatch'

RSpec.describe Dispatch do
  it 'should define the is_overloaded method' do
    expect(Dispatch).to respond_to :is_overloaded
  end

  it 'should return false by default' do
    expect(Dispatch.is_overloaded).to equal false
  end

  it 'should return true if the avg value is greater than 1' do
    data = []
    data << { "minute_intervals" => { "one" => 2 } }
    data << { "minute_intervals" => { "one" => 3 } }
    expect(Dispatch.is_overloaded(data, 2)).to equal true
  end

  it 'should return false otherwise' do
    data = []
    data << { "minute_intervals" => { "one" => 0.2 } }
    data << { "minute_intervals" => { "one" => 1 } }
    expect(Dispatch.is_overloaded(data, 2)).to equal false
  end
end
