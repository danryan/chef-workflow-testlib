require 'chef-workflow/support/scheduler'

$SCHEDULER ||= Scheduler.new

#
# Helper for provisioning. Intended to be instanced and assigned to the
# provision_helper attribute of a ProvisionedTestCase.
#
# All methods except `provision`, which is shorthand, are passed directly to
# the scheduler.
#
class ProvisionHelper
  def schedule_provision(*args)
    $SCHEDULER.schedule_provision(*args)
  end

  def deprovision(group_name)
    $SCHEDULER.deprovision_group(group_name)
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
