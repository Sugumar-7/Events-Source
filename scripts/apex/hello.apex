// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = Site.getBaseUrl();
System.debug('Hello World!');
System.debug('Site URL :  ' + tempvar);

System.debug('Site Base URL: ' + Site.getBaseUrl());
System.debug('Org Domain URL: ' + URL.getOrgDomainUrl().toExternalForm());
System.debug('Lightning Base URL: ' + URL.getOrgDomainUrl().toExternalForm());