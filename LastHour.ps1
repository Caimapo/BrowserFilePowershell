[CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$DEFAULT
    )

Function Get-LastHour($UserName, $DEFAULT) {

    $module = Get-Module -List PSSQLite

    if (!$module) {
        Write-Host "`nUnable to locate the PSSQLite module. Use the function 'Scrape-FirefoxHistory' instead." -ForegroundColor Yellow
        return
    }
    Import-Module PSSQLite

    $SQLiteDbPath = "$env:SystemDrive\Users\$UserName\AppData\Roaming\mozilla\firefox\Profiles\$DEFAULT\places.sqlite"

    if (-not (Test-Path -Path $SQLiteDbPath)){
        Write-Verbose "[*] Could not find the Firefox History SQLite database for user: $UserName"
        return
    }

    Invoke-SqliteQuery -DataSource $SQLiteDbPath -Query "SELECT url,title,visit_count,datetime(last_visit_date/1000000,'unixepoch','localtime') as date from moz_places WHERE datetime(last_visit_date/1000000, 'unixepoch', 'localtime') > datetime('now', 'localtime', '-1 hour');"

}

try{
    Get-LastHour $UserName $DEFAULT
    Write-Host "nFinish. Dumping database.`n" -ForegroundColor Green
} catch {
    throw $_
}
