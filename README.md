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
|Version|2.3.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007oePIAQ*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007og1IAA*
|GIT URL                  | https://github.com/jfwberg/lightweight-apex-unit-test-util-v2
|Name|Lightweight - Apex REST Util|
|Version|0.10.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007sN3IAI*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007sQHIAY*
|GIT URL                  | https://github.com/jfwberg/lightweight-rest-util

## Optional Dependencies
This package has an extension that adds a basic (error) logging functionality and a user mapping utility that allows the Auth Provider to work in a user context using "Per User" instead of "Named Principal".

| Info | Value |
|---|---|
|Name|Lightweight - Auth Provider Util v2|
|Version|0.10.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP3000000ET0XIAW*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP3000000ET6zIAG*
|GIT URL                  | https://github.com/jfwberg/lightweight-auth-provider-util

## Package info
| Info | Value |
|---|---|
|Name|Lightweight - Salesforce Auth Provider|
|Version|0.2.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP3000000EardIAC*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP3000000EawTIAS*

## Important
- Security is no easy subject: Before implementing this (or any) solution, always validate what you're doing with a certified sercurity expert and your certified implementation partner
- At the time of writing I work for Salesforce. The views / solutions presented here are strictly MY OWN and NOT per definition the views or solutions Salesforce as a company would recommend. Again; always consult with your certified implementation partner before implementing anything you've found on the internet.

## Setup
