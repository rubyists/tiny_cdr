require_relative "../../../lib/tiny_cdr"
require_relative "../../db_helper"
require_relative "../../cdr_data"
require_relative "../../../model/call"


require_relative "../../../model/log"

shared :call_spec do
  behaves_like :makedoc

  def bulk_insert(n)
    calls = Array.new(n){
      TinyCdr::Call.create_from_xml(makedoc)
    }
  end
end

describe 'TinyCdr::Call' do
  behaves_like :call_spec

  it 'should create the test dataset of 100 calls' do
    calls = bulk_insert(100)
    calls.first.class.should == TinyCdr::Call
    calls.size.should == 100
  end

  it 'should have a couch record for every postgres record' do
    TinyCdr::Call.count.should == 100
    TinyCdr::Call.all.map { |d| d.detail.class }.uniq.should == [TinyCdr::Log]
  end
end
