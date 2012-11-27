require 'minitest/unit'

class MiniTest::Unit::TestCase
  def self.before_suite; end
  def self.after_suite; end
end

class MiniTest::Unit::ProvisionedRunner < MiniTest::Unit
  def _run_suite(suite, type)
    begin
      suite.before_suite
      super(suite, type)
    ensure
      suite.after_suite
    end
  end
end

MiniTest::Unit.runner = MiniTest::Unit::ProvisionedRunner.new
