Write-Host ""
Write-Host "What would you like to do?"
Write-Host ""
Write-Host "A) Collect a new Baseline?"
Write-Host ""
Write-Host "B) Begin monitoring files with saved Baseline?"
Write-Host ""

$response = Read-Host -Prompt "Please Enter 'A' or 'B'?"
Write-Host "User Entered $($response)"

Function Calculate-File-Hash($filepath){
    $filehash= Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

 Function Erase-Baselinetxt-if-it-exists(){
  $BLexists = Test-Path -Path .\baseline.txt
  if($BLexists){
  #Delete it
  Remove-Item -Path .\baseline.txt
  }
 }
 
 #$hash= Calculate-File-Hash "C:\Users\user\Desktop\FIM\tests\a.txt"

if ($response -eq "A".ToUpper()){
   #Delete Baseline if it exists

   Erase-Baselinetxt-if-it-exists
   
   
    #Calculate Hash from target files and store them in baseline.txt
    
    #Collect all files in the folder that we need/want to monitor
    
    $files= Get-ChildItem -Path C:\Users\user\Desktop\FIM\tests

    #for each file, calc the hash and write it in the baseline.txt'
    foreach($f in $files){
    $hash= Calculate-File-Hash $f.FullName 
    #"$($hash.Path)|  |$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append but this will keep on adding to it and wont replace current hashes
    "$($hash.Path)||$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }
    
    
    
      
}



elseif($response -eq "B".ToUpper()){
    $fileHashDictionary= @{}
    
   # Load file|Hash from baseline.txt and store them in a dictionary 
    $filePathsAndHashes = Get-Content -Path .\baseline.txt 
    
    
    foreach($f in $filePathsAndHashes){
     
     $fileHashDictionary.add($f.Split("||")[0],$f.Split("||")[2])
     #$f.Split("||")[0/1]  
     #this will end up returning an array, and the zero-th element of the array should be the file path and first(but for me its the second for some reason) element should be the hash
    }
    
    #$fileHashDictionary.values

     
    #$fileHashDictionary.Add("path","hash")
    #$fileHashDictionary
    #$fileHashDictionary["qwe "] -eq $null

    #Begin (continuously) monitoring files with saved Baseline
    while($true){
        #loop running forever
        #calc the file hash for all files and when we calc'em we check inside the dictionary
        #if key exists, if not we know its new/added
        #if it does exist but hash is different then we know the hash is different

    Start-Sleep -Seconds 1

     $files= Get-ChildItem -Path C:\Users\user\Desktop\FIM\tests

    #for each file, calc the hash and write it in the baseline.txt'
    foreach($f in $files){
        $hash= Calculate-File-Hash $f.FullName 
    #"$($hash.Path)||$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    
    #Notify me if a new file has been created
      
        if($fileHashDictionary[$hash.Path] -eq $null){
        
             #A new file has been created
              Write-Host "$($hash.Path) has been created!!" -ForegroundColor Green
            }
            else{

            #Notify me if a new file has been changed
        if($fileHashDictionary[$hash.Path] -eq $hash.Hash){
            #The file has not been changed
        }
        else{
            #file has been compromised!! Notify User
            Write-Host "$($hash.Path) Has Changed!!!" -ForegroundColor Yellow
                }
        
            }
            }
            foreach($key in $fileHashDictionary.Keys){
            $BLStillExist = Test-Path -Path $key
            if(-Not $BLStillExist){
                #if one of the Baseline files mustve been deleted!! Ntofiy user
                Write-Host "$($key) has been deleted!!" -BackgroundColor Red
                
                }
            }
        }
    } 
