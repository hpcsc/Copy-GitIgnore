
<#PSScriptInfo

.VERSION 1.0

.GUID 809317ae-1ed5-475b-9f12-4e6496e87d77

.AUTHOR David Nguyen

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>


function Join-Parts {
    param ([string[]] $Parts, [string] $Seperator = '')
    $search = '(?<!:)' + [regex]::Escape($Seperator) + '+'  #Replace multiples except in front of a colon for URLs.
    $replace = $Seperator
    ($Parts | ? {$_ -and $_.Trim().Length}) -join $Seperator -replace $search, $replace
}

function Get-Content-And-Write($chosen)
{
    $content = Invoke-RestMethod -Method Get -Uri (&Join-Parts("https://raw.githubusercontent.com/github/gitignore/master/", $($chosen.path)) "/")
    New-Item ".gitignore" -ItemType file -Value $content
}

<# 

.Synopsis
 Search and clone .gitignore template

.Description
 A simple script to search and clone .gitignore template file from github/gitignore 

.Parameter fileName
 The file name (or part of file name) to search, excluding .gitignore extension

.Example
  # List all available .gitignore templates at the root of the repository.
  Copy-GitIgnore

.Example
  # List all available .gitignore templates at Global sub-directory of the repository.
  Copy-GitIgnore Global

.Example
  # Search all .gitignore templates with VisualStudio in their name.
  Copy-GitIgnore VisualStudio
#>
function Copy-GitIgnore([string]$fileName)
{
    $searchResult = Invoke-RestMethod -Method Get -Uri "https://api.github.com/search/code?q=$($fileName)+in:path+extension:gitignore+repo:github/gitignore" | 
        Select-Object -Property items
    $items = $searchResult.items

    If($items.Length -eq 0)
    {
        Write-Error "No .gitignore file found for $($fileName)"
    }
    ElseIf($items.Length -eq 1)
    {
        &Get-Content-And-Write($items[0])
    }
    Else
    {
        Write-Host "$($items.Length) results found"
        $i = 1
        $items | ForEach-Object { Write-Host "[$($i)] $($_.path)"; $i++ }

        Write-Host

        $chosenIndex = ""
        $parsed = 0
        While(!$chosenIndex -or ![int32]::TryParse($chosenIndex , [ref]$parsed) -or $parsed -le 0 -or $parsed -gt $items.Length)
        {
            $chosenIndex = Read-Host -Prompt "Choose index of .gitignore template to create"
        }

        &Get-Content-And-Write($items[$chosenIndex - 1])
    }
}

Export-ModuleMember -function Copy-GitIgnore