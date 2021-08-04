# frozen_string_literal: true

require 'apia/helpers'

describe Apia::Helpers do
  context '.class_name_to_id' do
    {
      'Example' => 'Example',
      'Example::Inner' => 'Example/Inner'
    }.each do |input, output|
      it "should convert #{input.inspect} to #{output.inspect}" do
        expect(Apia::Helpers.class_name_to_id(input)).to eq output
      end
    end
  end

  context '.camelize' do
    {
      'test' => 'Test',
      'another_test' => 'AnotherTest',
      'AnotherTest' => 'AnotherTest',
      'with2_a_number' => 'With2ANumber',
      'api' => 'Api',
      'test_Adam' => 'TestAdam',
      :symbol => 'Symbol',
      nil => nil
    }.each do |input, output|
      it "should convert #{input.inspect} to #{output.inspect}" do
        expect(Apia::Helpers.camelize(input)).to eq output
      end
    end
  end
end
