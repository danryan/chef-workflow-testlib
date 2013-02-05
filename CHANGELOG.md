* 0.2.0 (unreleased)
  * **important**: All chef-workflow-tasklib unit tests from now on should
    inherit from MiniTest::Unit::ProvisionedTestCase, what provisioners to use
    is determined by the configuration.
    * the EC2 and Vagrant-specific versions are going away in a future release.
  * Like all other parts of chef-workflow, all classes were prefixed with the namespace ChefWorkflow

* 0.1.1 December 21, 2012
  * Fix gemspec. Here's to touching the stove.

* 0.1.0 December 21, 2012
  * Initial public release
