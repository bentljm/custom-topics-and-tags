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

Package URLs

Managed Package:
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tHo000000C9WrIAK

Unmanaged Package:
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tHo000000C6RLIA0

## Misc Notes

Please select a Category, and then search for Topics! This is a great place to add additional information for Users such as instructions, custom labels, hyperlinks, etc.

Write a test class for this class. Make sure that if follows Salesforce Best Practices. Make sure that it will past Salesforce Security Review. Make sure that it is dynamic and bulkified. Make sure that has comments. 

Step 1. create Topic Configuration metadata records
- required fields, 

Label	ex. Services Account
Topic Configuration Name ex	Services_Account
Category	 ex Services	 	 
Object Visibility	ex Account	 	 
Object Field ex multi select picklist (optional) 	 	 
Icon Name	ex. utility:fulfillment_order	 	 
Pill Color	ex Light Blue	 	 
Pill Style ex Outline

- Determines which topic category are visible on each object

Step 2. drag and drop topicCardComponent onto lightning Record Detail page>
required fields
Card Title
Card Icon
Card Help Text
Object Api Name (same as object of lightning record page)
Topic Categories (comma-separated list of Categories visible to users on this page)

Step 3. Create Topic
required field
Topic Name
Category
Object Visibility (which objects can this Topic be added too)

Step 4. Go to object record, select Category or keep as All, search for Topic and select from drop down list. Selected topic will be added as pill to component. If object field is set for specific Category on specific object, topic will be added to specified multi select picklist and picklist value will be automatically activated on picklist field

Customizable tagging mechanism to track Topics across Objects. Enables users to associate Topics with object records to track a particular issue, theme, or subject across many objects. Also gives Administrators ability to manage and customize Topics.

HOW TO USE:
Step 1: Go to Topic object and add a Topic Category to the Category__c picklist field.

Step 2: Create Topic Configuration Metadata Records with the required fields (Label, Topic Configuration Name, Category, Object Visibility, Icon Name) and optional fields (Object Field, Pill Color, Pill Style).

Step 3: Drag and drop the "topicCardComponent" onto a Lightning Record Detail page and fill in required fields.

Step 4: Go to the "Topics" tab in Salesforce and create new Topic. Fill in the required fields (Topic Name, Category, Object Visibility) and optional Fields.

Step 5: Add Topic to Object Record. Navigate to a record of the object associated with the Lightning Record Page. Choose a specific Category or select "All." Search for the desired Topic and select it from drop down list to add it as a pill in the component. The pill color and style is determined by the respective custom metadata record associated to the category and object.
NOTE: If the Object Field is set for the specific category and object in the custom metadata record, the Topic will be added to the specified multi-select picklist and the value will be automatically activated.

Apex, Lightning Web Components, Custom Metadata, Custom App, Custom Tab, Metadata Service


