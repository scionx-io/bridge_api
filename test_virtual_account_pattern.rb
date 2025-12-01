#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/bridge_api'

# Sample virtual account data from the production error
sample_data = {
  id: "7f444e4d-9fbe-4a49-8f4c-cb084cf7ebde",
  status: "activated",
  developer_fee_percent: "0.0",
  customer_id: "f558b609-403f-4e88-8815-a1bc69c57159",
  created_at: "2025-11-24T02:44:09.939Z",
  source_deposit_instructions: {
    currency: "eur",
    iban: "LU774080000043534573",
    bic: "BCIRLULL",
    account_holder_name: "Bridge Building Sp. Z.o.o.",
    bank_name: "Banking Circle S.A.",
    bank_address: "2 Boulevard de la Foire, L-1528 Luxembourg",
    bank_beneficiary_name: "Bridge Building Sp. Z.o.o.",
    bank_beneficiary_address: "2 Boulevard de la Foire, L-1528 Luxembourg",
    payment_rails: ["sepa"]
  },
  destination: {
    currency: "usdc",
    payment_rail: "polygon",
    address: "0xfa7ba087278f5aa5a466746e712273912da85dc2"
  }
}

puts "Testing virtual account pattern matching..."
puts "=" * 60

# Test the conversion
result = BridgeApi::Util.convert_to_bridged_object(sample_data, resource_hint: 'virtual_account')

puts "Input data class: #{sample_data.class}"
puts "Result class: #{result.class}"
puts "Expected class: BridgeApi::Resources::VirtualAccount"
puts ""

if result.is_a?(BridgeApi::Resources::VirtualAccount)
  puts "✅ SUCCESS! Data converted to VirtualAccount object"
  puts ""
  puts "Testing accessor methods:"
  puts "  result.id: #{result.id}"
  puts "  result.status: #{result.status}"
  puts "  result.developer_fee_percent: #{result.developer_fee_percent}"
  puts "  result.customer_id: #{result.customer_id}"
  puts "  result.source_deposit_instructions: #{result.source_deposit_instructions.class}"
  puts ""
  puts "✅ All accessor methods work correctly!"
else
  puts "❌ FAILED! Data is still a #{result.class}"
  puts "This means the pattern matching didn't work."
  exit 1
end
