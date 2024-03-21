# terraform-azure
Terraform modules for Azure resources built _the Sound Way_

## Assumptions

_The Sound Way_ makes certain assumptions about naming conventions and environments. _The Sound Way_ also expects that each project will have 2 subscriptions. The first subscription is named _DevTest_ and is where all pre-production resources are built. The second subscription is named _Prod_ and is where all production and staging resources are built.

### Environments

_The Sound Way_ expects every project to have the following environments and to have the environment passed in as part of building resources. This environment becomes part of the naming convention for resources.

* TDD: The testing driven development environment. Deployed on every commit, this environment can be quickly spun up and torn down to validate the build and deployment process. This can be used for basic BVT (Build Validation Testing) but should not be depended on. This environment exists only in the  _devtest_ subscription.
* DEV: The development environment. This is the second environment in the project. This environment can be created and deployed either on commit or on demand. This is more stable than the TDD environment, but not much more. It tends to be used for manual system validation by developers. This environment exists only in the  _devtest_ subscription.
* TST: The test environment. This is used primarily by the QA team, but also may be used for UAT (User acceptance testing) if there is no staging environment. This environment exists only in the  _devtest_ subscription.
* UAT: The user acceptance testing environment. This is used primarily for UAT (User acceptance testing) if there is no staging environment. This environment exists only in the  _devtest_ subscription.
* PRD: The production environment. This environment is more stable and tends to be deployed manually, either via a user clicking a release button or via checking in code into a specific branch. This environment exists only in the  _prod_ subscription. 

### Naming Conventions 

_The Sound Way_ expects that every resource follows our naming conventions. All of the following elements are separated by dashes, where allowed. Exceptions to these are storage accounts where only alpha characters are allowed. The naming conventions are as follows:

* All resources names will have a prefix that ties them to the project. These prefixes are used in naming of subscriptions. These prefixes are typically 3 to 4 characters in length and unique to the project, e.g. _sbs_ for Sound Billing Service or _php_ for Population Health Project

* All resources names will follow the project prefix with the environment abbreviation. Valid values are described in the [Environments](#environments) section.

* All resources names will follow the environment name with the abbreviation of the type of that resource. 

    * rg - Resource Group
    * sa - Storage Account
    * asplan - App Service Plan
    * fn - Function App
    * acr - Container Registry
    * aci or cg - Container Instance
    * sqlserver - SQL Server
    * sqldb - SQL Database
    * vnet - Virtual Network

* If multiple resources of the same type will be created in the same resource group, a suffix should be added to the names of those resources to distinguish them. 

#### Examples

Given the following variables, the expected resource names are as follows:

* Project name: Sound Billing Service
* Project prefix: sbs 
* Environment name: tst 
* Suffix: blah

Expected resource names:
* Resource group: sbs-tst-rg-blah
* Storage account: sbststsablah
* Function app: sbs-tst-fn-blah

## Usage 

```hcl
resource "azurerm_resource_group" "group" {
    name = var.resource_group_name 
    location = var.location 
}

module "my_function" {
  source  = "github.com/soundphysicians/terraform-azure//modules/azure-function?ref=<CommitHash>"

  prefix               = var.prefix
  environment          = var.environment
  resource_group_name  = azurerm_resource_group.group.name
  location             = azurerm_resource_group.group.location
  base_name            = "myfunc"
  app_insights_key     = var.application_insights_instrumentation_key
  function_environment = "Development"         

  app_settings = {
      MySetting = "MyValue"
  }
}

module "acr" {
  source  = "github.com/soundphysicians/terraform-azure//modules/azure-container-registry?ref=<CommitHash>"

  project             = var.prefix
  environment         = var.environment
  subscription_id     = var.registry_subscription_id
  resource_group_name = var.registry_group_name
  name                = "mycontainerregistry" 
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->