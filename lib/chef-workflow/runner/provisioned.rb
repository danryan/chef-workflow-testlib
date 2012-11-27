require 'minitest/unit'

class MiniTest::Unit::TestCase
  def self.before_suite; end
  def self.after_suite; end
end

class MiniTest::Unit::ProvisionedRunner < MiniTest::Unit
  def _run_suite(suite, type)
    begin
      suite.before_suite unless suite.test_methods.empty?
      super(suite, type)
    ensure
      suite.after_suite unless suite.test_methods.empty?
    end
  end
end

MiniTest::Unit.runner = MiniTest::Unit::ProvisionedRunner.new
