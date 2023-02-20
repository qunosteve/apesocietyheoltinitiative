# Ape Society Heolt Initiative from King Rad White
Powershell Script that Runs a Cardano Blockchain-wide Snapshot of Heolt Cabins, Ghosts, and Apes for King White's Ghostchain staking Initiative. Made this script open source so anyone can run and validate for themselves. You can use this solution to verify your stake address's eligibility for the initiative (this is what the White family will use for snapshots as well).

Requirements to participate in this initiative:

1. Hold any ape society family. 
2. Hold a cabin in Heolt (District 1). 
3. Hold one ghostchain nft in the same wallet as your Heolt cabin. 
4. Maximum of three sets of apes,ghosts,heolt cabins.

More info on this initiative here (note this is separate from the Amphitheatre Warhammer initiative that will come later down the road): https://theapesociety.gitbook.io/digest/the-ape-society-digest/apes/craftsmen/families/white/notable-apes/radcliff-white/king-whites-statement

## Install/Run Instructions

1) Download all files (apes.csv, ghosts.csv heoltCabins.csv, heoltGhostchaininitiative.ps1) from this repository https://github.com/qunosteve/apesocietyheoltinitiative/  and save the files to a directory on your pc (keep them all in the same directory).

2) In that same directory, create a file named "project_id.txt" and paste your blockfrost mainnet project_id into the first line of that file and save. If you don't have a blockfrost account, go to https://blockfrost.io/ and sign up. On your dashboard there should be an area with some sample queries. Look for a code that starts with "mainnet". That's most likely your API key.

3)  After the "project_id.txt" is created and saved to the same directory as the .ps1 and .csv files, right click on "heoltGhostchaininitiative.ps1" and click "Run with Powershell". If the script is allowed to run on your computer you should see a console with line by line feedback on what is happening with the script (which addresses are loaded, etc).

4) If the script isn't allowed to run, you might need to set execution policy to remotesigned or bypass. Look at the official documentation from microsoft here: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.3


Good luck on your hunt to maximize your stake address's multiplier (3 is the max for this initiative). If you need to find your stake address, plug in your addr or your ada handle into a blockchain explorer like https://cexplorer.io/ .

Note: Last time this was ran it used 1250 Requests & took 12min on i7-2600k w/ 1600MHz memory. At the time of this writing, the free blockfrost account allows 50,000 requests per day.
