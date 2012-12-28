require 'chef-workflow/support/general'
require 'chef-workflow/support/scheduler'
require 'chef-workflow/support/vm/helpers/knife'

$SCHEDULER ||= ChefWorkflow::Scheduler.new

module ChefWorkflow
  #
  # Helper for provisioning. Intended to be instanced and assigned to the
  # provision_helper attribute of a ProvisionedTestCase.
  #
  # All methods except `provision`, which is shorthand, are passed directly to
  # the scheduler.
  #
  class ProvisionHelper

    include ChefWorkflow::KnifeProvisionHelper

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
      schedule_provision(
        group_name, 
        [
          ChefWorkflow::GeneralSupport.singleton.machine_provisioner.new(group_name, number_of_servers), 
          build_knife_provisioner
        ], 
        dependencies
      )
    end
  end
end
