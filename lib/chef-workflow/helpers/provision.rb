require 'chef-workflow/support/scheduler'

$SCHEDULER ||= Scheduler.new

class ProvisionHelper
  def schedule_provision(*args)
    $SCHEDULER.schedule_provision(*args)
  end
  
  def wait_for(*args)
    $SCHEDULER.wait_for(*args)
  end

  def serial=(arg)
    $SCHEDULER.serial = arg
  end

  def run
    $SCHEDULER.run
  end

  def provision(group_name, number_of_servers, dependencies)
    raise "Please override this method"
  end
end
