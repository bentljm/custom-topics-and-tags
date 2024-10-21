# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## SF Package CLI

sfdx force:auth:web:login -d -a DevHub

sf org create scratch --definition-file config/project-scratch-def.json --no-namespace --alias MyScratchOrg#

sf org open --target-org MyScratchOrg#

sf package list 

sf package version list 

sf package version list --verbose

sf package create --name TopicsAppUnmanaged --package-type Unlocked --path force-app

sf package version create --package TopicsAppUnmanaged --installation-key-bypass --code-coverage

sf package create --name TopicsApp  --package-type Managed --path force-app

sf package version create --package TopicsApp --installation-key-bypass --code-coverage

sf package install --package <package version id> --target-org <scratch org username>

sf package version promote --package 04tHo000000C9WrIAK

cd ~/.sfdx

## Login Info:

Listing:
https://appexchange.salesforce.com/partners/listing-editor?id=bd3fa3e9-7231-45cb-834c-83fa33d16298

Security Review:
https://appexchange.salesforce.com/partners/security-review-editor?packageVersionId=04tHo000000t6OLIAY

Partner Community Login:
support@salesforceinnovationshub.com
GoFalcons@@12
salesforcesolutions@gmail.com

PBO/DEV HUB:
support@salesforceinnovationshub.com
GoFalcons@@12

Dev:
support@salesforceinnovationshub.com.dev
GoFalcons@@12

Development:
support@salesforceinnovationshub.com.developer
GreatIsOurGod@@12

Development2:
support@salesforceinnovationshub.com.developertwo
GreatIsOurGod@@12

Test Org:
testuser@salesforceinnovationshub.com
GreatIsOurGod@@12

Test Org (Old):
test@salesforceinnovationshub.com
GoTopics@@12

Package URL:
Managed Package
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tHo000000C9WrIAK

Unmanaged Package:
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tHo000000C6RLIA0
