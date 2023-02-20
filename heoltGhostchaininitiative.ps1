Function Get-UniqueHeoltAddresses {
    
    #Import Heolt Cabin Source File data
    $heoltMetadata = Import-Csv -Path $heoltCabinSourceFile

    #Instantiate unique and nonunique heolt cabin Cardano blockchain address arrays.
    $uniqueHeoltAddresses = @()
    $heoltAddresses= @()
    
    #Loop through the heolt cabin source file data.
     foreach ($heoltCabin in $heoltMetadata) 
    {
        #Construct and execute blockfrost query to get address associated with asset in loop instance.
        $assetURL = "https://cardano-mainnet.blockfrost.io/api/v0/assets/$($heoltCabin.asset)/addresses"
        $address = Invoke-WebRequest -URI  $assetURL -Headers $headers -ContentType "application/json" | ConvertFrom-Json

        #Check if address is on the blacklist.
        if ($blackList -notcontains $address[0].address)
        {
            #Construct and execute blockfrost query to get stake address associated with address. using address[0] as these are CIP-25 tokens so only 1 address should be returned per token.
            $addressURL = "https://cardano-mainnet.blockfrost.io/api/v0/addresses/$($address[0].address)"
            $stakeAddress = Invoke-WebRequest -URI  $addressURL -Headers $headers -ContentType "application/json" | ConvertFrom-Json

            #Check for empty stakeaddress
            if ($stakeAddress.stake_address)
            {
                #Check to see if stake address is on the blacklist
                if ($blackList -notcontains $stakeAddress.stake_address)
                {
                    #Check for duplicate stake address to conserve api calls later during account-based asset lookup.
                    if ($heoltAddresses -notcontains $stakeAddress.stake_address)
                        {
                            #Add address to unique stake address array.
                            $uniqueHeoltAddresses += $stakeAddress.stake_address

                            #Log Entry.
                            if ($consoleLoggingEnabled)
                            {
                                Write-Host "Added $($stakeAddress.stake_address) to Heolt Owners."
                            }
                        
                        #Else logs if the stake address is a duplicate.
                        } else 
                            {
                               #Log entry.
                               if ($consoleLoggingEnabled)
                               {
                                    Write-Host "Omitted $($stakeAddress.stake_address) as Duplicate."
                               } 
                           
                            }
                    #Regardless if duplicate, Add stake address to unfiltered list of stake addresses to check for duplicates later in the loop.
                    $heoltAddresses += $stakeAddress.stake_address
                }
            #Else branch defines instructions if there is no stake address for this address.
            } else 
                {
                    #Check if addr is on Blacklist.
                    if ($blackList -notcontains $address[0].address)
                    {
                        #Check for duplicate addr to conserve api calls later during account-based asset lookup.
                        if ($heoltAddresses -notcontains $address[0].address)
                            {
                                #Add addr to unique addr list
                                $uniqueHeoltAddresses += $address[0].address

                                #Log entry.
                                if ($consoleLoggingEnabled)
                                {
                                    Write-Host "Added $($address[0].address) to Heolt Owners."
                                }

                            #Else logs if the addr is a duplicate.
                            } else 
                                {
                                   #Log entry.
                                   if ($consoleLoggingEnabled)
                                   {
                                        Write-Host "Omitted $($address[0].address) as Duplicate."
                                   } 
                                }
                        #Regardless if duplicate, Add addr to unfiltered list of stake addresses to check for duplicates later in the loop.
                        $heoltAddresses += $address[0].address
                    }
                }
        }
    }

    #Returns array of unique Heolt cardano addresses
    return $uniqueHeoltAddresses
}

Function Get-TokensFromAddress ($addressList) {
    
    #Enter loop to check each address for assets
    foreach ($address in $addressList)
    {
            #Each address's variables such as array of assets
            $assets = @()
        
            #Loop Variables
            $page = 1
            $exitLoop = 0
        
            #While new assets are being found
            while ($exitLoop -eq 0)
            {
                #Log Entry
                if ($consoleLoggingEnabled)
                {
                    Write-Host Asset Page $page for $address 
                }
            
                #Build and run Blockfrost query to get assets tied to address
                $assetsbyStakeAddressURL = "https://cardano-mainnet.blockfrost.io/api/v0/accounts/$($address)/addresses/assets?page=$($page)"
                $assetsbyStakeAddress = Invoke-WebRequest -URI  $assetsbyStakeAddressURL -Headers $headers -ContentType "application/json" | ConvertFrom-Json

                #Add assets to array
                $assets += $assetsbyStakeAddress.unit           

                #Check if there are more assets (more pages) to query
                if ($assetsbyStakeAddress.Count -lt 100)
                    {
                        #If less than 100 on current page, exit blockfrost query asset loop
                        $exitloop = 1

                        #Log Total Assets found with this address
                        if ($consoleLoggingEnabled)
                        {
                            Write-Host Total Assets for $address : $assets.Count
                        } 
                    }

                #Increment Page
                $page ++
            }

            #Check how many Eligible Heolt Cabins this address has
                #Log Entry
                if ($consoleLoggingEnabled)
                {
                    Write-Host Cabin Check for $address
                }
            $numHeoltCabins  = Check-HeoltCabins $assets

            #Check how many Eligible Apes this address has
                #Log Entry
                if ($consoleLoggingEnabled)
                {
                    Write-Host Ape Check for $address
                }
            $numApes = Check-Apes $assets

            #Check how many Eligible Ghosts this address has
                #Log Entry
                if ($consoleLoggingEnabled)
                {
                    Write-Host Ghost Check for $address
                }
            $numGhosts = Check-Ghosts $assets

            #Aggregate all variables and calculate/output Eligibility to file
            Calculate-Eligibility $address $numHeoltCabins $numApes $numGhosts
    }
}

Function Check-HeoltCabins ($tokenList) {

    #Import Heolt Cabin Source File data
    $heoltMetadata = Import-Csv -Path $heoltCabinSourceFile

    #Instantiate number of cabins per address
    $numCabins = 0
    
    #Loop through the tokenList to check if a cabin exists.
    foreach ($token in $tokenList)
        {
            #Check if the token exists in the heolt cabins file.
            if ($heoltMetadata.asset -contains $token)
            {
                #If so, add to the amount of eligible cabins.
                $numCabins ++

                #Check if number of cabins has reached the cap.
                if ($numCabins -ge $maxCabins)
                {
                    #If cap reached, break out of loop.
                    break
                }   
            }
        }

    #Returns number of eligible cabins found.
    return $numCabins
}

Function Check-Apes ($tokenList) {

    #Import Ape Source File data.
    $apeMetadata = Import-Csv -Path $apeSourceFile

    #Instantiate number of apes per address.
    $numApes = 0
    
    #Loop through the tokenList to check if an ape exists.
    foreach ($token in $tokenList)
        {
            #Check if the token exists in the Ape source file.
            if ($apeMetadata.asset -contains $token)
            {
                #If so, add to the amount of eligible apes.
                $numApes ++

                #Check if number of apes has reached the cap.
                if ($numApes -ge $maxCabins)
                {
                    #If cap reached, break out of loop.
                    break
                }   
            }
        }

    #Returns number of eligible apes found.
    return $numApes
}

Function Check-Ghosts ($tokenList) { 
    #Import Ghost Source File data
    $ghostMetadata = Import-Csv -Path $ghostSourceFile

    #Instantiate number of Ghosts per address
    $numGhosts = 0
    
    #Loop through the tokenList to check if a Ghost exists
    foreach ($token in $tokenList)
        {
            #Check if the token exists in the Ghost source file
            if ($ghostMetadata.asset -contains $token)
            {
                #If so, add to the amount of eligible Ghosts.
                $numGhosts ++

                #Check if number of ghosts has reached the cap
                if ($numGhosts -ge $maxCabins)
                {
                    #If cap reached, break out of loop.
                    break
                }   
            }
        }

    #Returns number of eligible ghosts found
    return $numGhosts            
}

Function Calculate-Eligibility ($address, $cabins, $apes, $ghosts) {
    
    #Aggregate numassets into array and get minimum
    $tokenAggregator = $cabins,$apes,$ghosts
    $multiplier = $tokenAggregator | Measure-Object -Minimum

    $outputString = $address+","+$cabins+","+$apes+","+$ghosts+","+$multiplier.Minimum 

    #Output to file
    $outputString >> $outFile

    #Log Entry
    if ($consoleLoggingEnabled)
    {
        Write-Host "Output to file: $($outputString)"
    }

}

#USER VARIABLES
#Output File. What do you want to name the output file?
$outFile = $PSScriptRoot+"\heoltGhostStakingIniative.csv"

#Enable/Disable Powershell ISE Console Logging with 0 or 1. Default is 0 for no logging.
$consoleLoggingEnabled = 0

#Blockfrost Project ID file path. Make a txt file and paste in your blockfrost project_id in the first line of the file
$projectIDFilePath = $PSScriptRoot+"\project_id.txt"

#Source File Information. Make sure these files are in the same directory as the script
$heoltCabinSourceFile = $PSScriptRoot+"\heoltCabins.csv"
$apeSourceFile = $PSScriptRoot+"\apes.csv"
$ghostSourceFile = $PSScriptRoot+"\ghosts.csv"

#blacklist addresses that are likely marketplaces/lending protocols/etc that will use up unneccessary API calls. the script will omit these addresses in asset lookups
$blackList = "addr1zxgx3far7qygq0k6epa0zcvcvrevmn0ypsnfsue94nsn3tvpw288a4x0xf8pxgcntelxmyclq83s0ykeehchz2wtspks905plm", "stake1uxqh9rn76n8nynsnyvf4ulndjv0srcc8jtvumut3989cqmgjt49h6", "addr1wxwrp3hhg8xdddx7ecg6el2s2dj6h2c5g582yg2yxhupyns8feg4m"

#Maximum eligible cabins per address in this initiative
$maxCabins = 3



#MAIN
#Get Blockfrost API Key from id from project_id.txt file and put into webrequest header
$projectID = Get-Content $projectIDFilePath -First 1
$headers = @{
    "project_id"="$($projectID)"
    }

#Populate column header info in output file
"address,eligibleCabins,eligibleApes,eligibleGhosts,multiplier" > $outFile


#Start collecting unique addresses based on Heolt Cabin ownership
    if ($consoleLoggingEnabled)
    {
        Write-Host ""
        Write-Host "-----------Collecting Heolt Owner Information-----------"
        Write-Host ""
    }
$stakeAddresses = Get-UniqueHeoltAddresses


#Start collecting token/asset information from address info collected from Heolt ownership
    if ($consoleLoggingEnabled)
    {
        Write-Host ""
        Write-Host "-----------Collecting Asset Info from Addresses-----------"
        Write-Host ""
    }
Get-TokensFromAddress $stakeAddresses