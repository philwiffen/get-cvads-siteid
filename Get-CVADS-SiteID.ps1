# Get-CVADS-SiteID
# This script will get a bearer token from the Citrix Cloud Trust Service, and then use that to get your CVADS Site ID from the CVADS API
# By Phil Wiffen
 
# Fill in your Citrix Cloud customerID and Secure Client details below, between the quote marks (you get these from Citrix Cloud > Identity and Access Management > API Access)
$customerID = ""
$clientID = ""
$clientSecret = ""

<# Example, in case it helps:
$customerID = "companycustomerid"
$clientID = "f539b28c-6f93-93c2-b526-49c48289f62e"
$clientSecret = "FDFLG3fgGKDKD=="
#>

#URL we'll call for the trust service to get the bearer token
$trustUri = "https://trust.citrixworkspacesapi.net/$customerID/tokens/clients"

# and the URL for the CVADS APIs. Currently this is tech preview:
$CVADSAPIUri = "https://$customerID.xendesktop.net/citrix/orchestration/api/techpreview/me"

 
#create a hash table for the body and headers: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7
$tokenrequestbody = @{ 
    "ClientId" = "$clientID";
    "ClientSecret" = "$clientSecret";
    }
$tokenrequestheaders = @{ 
    "Accept" = "application/json";
    "Content-Type" ="application/json";
    }
 
#must convert the body to JSON, otherwise you get error "Invoke-RestMethod : {"message":"The request is invalid.","modelState":{"credentials":["An error has occurred."]}}"
$getBearerToken = Invoke-RestMethod -Method "POST" -Uri $trustUri -Body (ConvertTo-Json $tokenrequestbody) -Headers $tokenrequestheaders

$bearerToken = $getBearerToken.token
Write-Host "Your Bearer Token for the next 60 minutes is:"
Write-Host "$bearerToken"
 
Write-Host "Authorization Header will be:"
Write-Host "Bearer $bearerToken"

#setup the headers for passing the bearer token to CVADS API:
$CVADSAPIHeaders = @{ 
        "Authorization" = "Bearer $bearerToken";
        }

#Now we call the CVADS API with the bearer token, and use that to get the CVADS Site ID

$getCVADSSiteID = Invoke-RestMethod -Method "GET" -Uri $CVADSAPIUri -Headers $CVADSAPIHeaders


Write-Host "CVADS information is:"
Write-Host $getCVADSSiteID.Customers

Write-Host "SiteID is: "$getCVADSSiteID.Customers.Sites.Id""
