# Lightweight - Salesforce Auth Provider
A lightweight Auth Provider to connect to external Salesforce through a Named Credentials or External Data Sources / External Objects / Cross Org Adapter.
Implements a solution for user context in a "Per User" authorization mode.

## Per User Setup
Details on setting up per user mode can be found here:
https://github.com/jfwberg/lightweight-auth-provider-util

## Dependency - Package Info
The following package need to be installed first before installing this package. (In this order)
If you use the *managed package* you need to installed the managed package dependency and if you use the *unlocked version* you need to use the unlocked dependency.
| Info | Value |
|---|---|
|Name|Lightweight - Apex Unit Test Util v2|
|Version|2.4.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP3000000M6OXIA0* |
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP3000000M6Q9IAK* |
|Github URL | https://github.com/jfwberg/lightweight-apex-unit-test-util-v2|
| | |
|Name|Lightweight - Apex REST Util|
|Version|0.11.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP3000000M6gHIAS* |
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP3000000M6htIAC* |
|Github URL | https://github.com/jfwberg/lightweight-apex-rest-util |

## Optional Dependencies
This package has an extension that adds a basic (error) logging functionality and a user mapping utility that allows the Auth Provider to work in a user context using "Per User" instead of "Named Principal".

| Info | Value |
|---|---|
|Name|Lightweight - Auth Provider Util v2|
|Version|0.12.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP3000000MVUzIAO*   |
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP3000000MW1FIAW*   |
|GIT URL                  | https://github.com/jfwberg/lightweight-auth-provider-util |

## Package info
| Info | Value |
|---|---|
|Name|Lightweight - Salesforce Auth Provider|
|Version|0.3.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP3000000MCLtIAO*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP3000000MCNVIA4*

## Important
- Security is no easy subject: Before implementing this (or any) solution, always validate what you're doing with a certified sercurity expert and your certified implementation partner
- At the time of writing I work for Salesforce. The views / solutions presented here are strictly MY OWN and NOT per definition the views or solutions Salesforce as a company would recommend. Again; always consult with your certified implementation partner before implementing anything you've found on the internet.

## Assign permissions to Automated Process User
Since the Spring 24 release platform events started running as the Automated Process User. Making the logging fail due to access issue. Only run this if you are planning on using the "Lightweight - Auth Provider" Util Package
To fix this I created a specific permission set for this user that can be assigned using the code below.
```java
insert new PermissionSetAssignment(
    AssigneeId      = [SELECT Id FROM User          WHERE alias = 'autoproc']?.Id,
    PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name  = 'Lightweight_Auth_Provider_Util_AutoProc']?.Id
);
```
