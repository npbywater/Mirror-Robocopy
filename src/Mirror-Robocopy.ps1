#**************************************************
# Author: Nick Bywater
# Government agency: National Park Service
# Created in year/month: 2022-November
# License: Public Domain
#**************************************************

<#
.SYNOPSIS
PROGRAM: Mirror-Robocopy
VERSION: 1.1 (2022-12-05)
- ISSUE: If there is only one source/directory combination (from the
  CSV file), then you can't use 'MENU 2' to mirror just that one
  combination (at index '0'). If you have more than one
  source/directory combination, you can then select one combination,
  and it will work via 'MENU 2'. 'MENU 1' works regardless; it mirrors
  everything; doesn't require using an index.
  - FIX: Convert the value returned by 'Contruct-PathHash' to an array
    of one hash. This must be done because 'Construct-PathHash'
    returns only the hash, instead of an array of one hash when there
    is only one hash in its local '$hash_array' variable. If there are
    more than one hash, 'Construct-PathHash' returns an array of
    hashes as expected.
- Take into account dynamic typing of variables in Powershell. Move
  the global variable 'g_runMode' into the Start-Up function.
- Add conditional code to function 'Start-Up' so that the program
  exits if there are no source/target paths in the CSV file.

VERSION: 1.0 (2022-12-01)
- Initial release.

This program takes a list of source and target directories from a CSV
file and offers the user the opportunity to MIRROR (via Robocopy) the
source directory into the target directory.

.DESCRIPTION

This program loads a list of source and target directories from a CSV
file and presents the user with a set of menus ('MENU 0', 'MENU 1' and
'MENU 2') that the user steps through in order to either:

- MIRROR each source directory to its corresponding target directory.
- MIRROR ONE selected combination of source/target directories from a
  the list of all source/target directorie.

NOTE: The CSV file first record must have two columns; 'source_dir'
and 'target_dir'. For example, a CSV file in Excel, might look like
this:

source_dir    target_dir
c:\path1      d:\path1\abc
c:\path2      d:\path2

START UP:
The file 'run_mirror_robocopy.ps1' is a short start-up script that
passes the required arguments to file 'Mirror-Robocopy.ps1' (which
contains the application). The file 'run_mirror_robocopy.ps1' would be
executed within the shell to start the application. However, you can
create a shortcut of this file, and then edit the properties of the
shortcut so that you can double click on the shortcut to start the
application without using a shell.

The 'target' field of the shortcut would be:

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "& '.\run_mirror_robocopy.ps1'"

The 'start in' field of the shortcut is the directory that that
contains the file 'run_mirror_robocopy.ps1'.

MENU 0:
- This menu is the start-up menu.
  - It informs the user, with warnings, that this program uses the
    Microsoft Robocopy program to MIRROR from source dirctories to
    corresponding target directories. It defines MIRRORing as:

    "Deletes from the target directory all files and directories that
    don't exist in the source directory; it then copies all files and
    directories from the source directory to the target directory,
    that don't exist in the target directory."

  - At the prompt it asks the user whether they wish to proceed or
    quit program.

PATH VALIDATION:
- Before 'MENU 1' is opened, and after entering 'y' in 'MENU 0',
  'Mirror-Robcopy' attempts to validate the source and target
  directory paths loaded from the CSV file 'path_list.csv'.
  - It performs four tests:
    1. Do all of the source/target paths exist?
    2. Are any of the source/target directory paths malformed?
       - 'Malformed' paths are paths that are not form in valid way.
    3. Are all of the source/target directory paths absolute paths?
    4. Are the paths either drives (like 'c:\') or share paths (like
       '\\<server name><share name>')?
      - These path designations are not allowed.
      - We don't want to mirror from a source drive into another
        drive, unless we take care to except the hidden system
        sub-directories.

    If any of the above tests do not pass, then the following error
    will appear. Also, the program will EXIT. You must fix these path
    issues before the program will continue to 'MENU 1'.

    The above lists may contain directory paths that
    - are either MALFORMED or DO NOT EXIST.
    - are only DRIVES or RELATIVE paths. Or UNC paths are of the form
      '\\<server name><share name>'. None are allowed.
      - Mirrors can only be made into sub-directories. Not drive to
        a drive or a server share.
      - This way we don't have to exclude hidden system directories.
    This program will not run unless these paths are
    fixed. NOTE: Only absolute paths are allowed.

MENU 1:
- This menu is the first menu that opens after entering 'y' (yes) at
  the prompt in 'MENU 0'.
  - If the program has validated the directory paths, as described
    above, you will see the following menu options:

    Enter one of the options below at the prompt, and press Enter.
    View file paths:
    a) View source/target paths.
    b) View source paths.
    c) View target paths.

    m) Mirror ALL source directories to target directories.
    o) Mirror just ONE source path out of all paths (opens another menu).
    t) Toggle 'TEST' and 'MIRROR' mode.

    CURRENT RUN MODE: TEST

    - The above options are self-explanatory for the most part.
      Options 'a', 'b', and 'c' give the user the ability to view the
      source/target paths in various ways.
    - The 'm' option will MIRROR each source directory to its
      corresponding target directory.
      - NOTE: The default 'CURRENT RUN MODE' is 'TEST'. That is, if
        the 'm' option is chosen when in TEST mode, then the Robocopy
        script will be executed with the '/L' option. This option does
        a "dry-run" of the MIRROR operation. That is, it performs a
        test run of the MIRROR operation, without actually performing
        the MIRROR (no directories or files are copied, or deleted).
        It logs this test MIRROR as if it had actually performed a
        real MIRROR.
    - You must toggle the 'TEST' mode to 'MIRROR' mode in order to
      perform a REAL MIRROR of the source directory to its
      corresponding target directory. To toggle this mode, enter 't'
      at the prompt.
      - Executing the 'm' option with the mode as 'MIRROR' will run an
        actual MIRROR operation (directories and files will possibly
        be copied to and deleted from the target directory).

    - Option 'o' opens 'MENU 2'. See descripton below.

MENU 2:
- This menu provides options for MIRRORing one combination of
  source/target directories from a list of all source/target
  directories.
  - It provides the user with the following options:

    a) View source/target paths.

    p) Return to previous menu.
    t) Toggle 'TEST' and 'MIRROR' mode.

    This menu allows you to robocopy ONE source/target path
    combination.

    To MIRROR, enter at the prompt the INDEX NUMBER of ONE of the
    source/target path combinations (listed above) and press Enter.

    CURRENT RUN MODE: TEST

  - Option 'a' will list all of the source/target directory
    combinations.
    - Each source/target combination has an INDEX number associated
      with it.
    - Enter INDEX of one of the source/target directory paths at the
      prompt and press the 'Enter' key to MIRROR the source/target
      directories with this INDEX.
      - Again, the 'CURRENT RUN MODE' determines how the MIRROR will
        be performed. Toggle this mode with option 't'.
  - Option 'p' will take the user back to 'MENU 1'.

LOGGING:
- This program writes the logs produced by Robocopy to the directory
  specified by parameter 'robocopy_log_dir'.
- Each log file has the following format:
  <target directory name>_<date>T<time>_<test or mirror>.log
  - The <test or mirror> part indicates whether the program was
    run in 'TEST' or 'MIRROR' mode.

ROBOCOPY:
The robocopy switches are set rather conservatively in this program.
They use the default number of threads (so it may be slow), and the
log files (in '.\logs') only shows changes that have occurred. Note,
if no changes have occurred, Robocopy logs all of the directories for
some reason (this may be because I require it to mirror directory
times). A future revision may allow the user to specify different
robocopy script options. Also, it will give up on the MIRROR quickly,
if a problem occurs (the retry '/R' and wait '/W' options are set to
'1'). The options are expanded to this in the log:

/S /E /DCOPY:T /COPY:DAT /PURGE /MIR /NP /R:1 /W:1

But, in the code, they look like this:

/R:1 /W:1 /MIR /NP /DCOPY:T

.PARAMETER csv_dir_list_file
Specifies the path to the CSV file that contains a list of source and
target directories.

.PARAMETER robocopy_log_dir
Specifies the path to the log directory where the Robocopy logs will
be written.
#>

param ([Parameter(Mandatory=$True)]
       [string]$csv_dir_list_file,
       [Parameter(Mandatory=$True)]
       [string]$robocopy_log_dir)

$version = "v1.1 (2022-12-05)"

## MENUS ##
function Show-Menu0 {
    $prompt = "
    ***** MENU 0 *****

    Program: Mirror-Robocopy
    Version: $version

    ***WARNING*** This interactive program MIRRORs

    (Deletes from the target directory all files and directories that don't
    exist in the source directory; it then copies all files and directories from
    the source directory to the target directory, that don't exist in the target
    directory.)

    files and directories from SOURCE to TARGET directories listed in the CSV
    configuration file:

    $csv_dir_list_file

    This program uses the command line program 'robocopy' to accomplish this
    mirroring of files and directories.

    You MUST make sure that you have specified the correct source and target
    directories; a MIRROR copy operation can DELETE (or PURGE) the ENTIRE
    contents of a target directory. For example, MIRRORing an empty source
    directory into a target directory will delete the entire target directory.

    The MIRRORing operation does NOT start when you choose 'y' at the prompt
    below. Rather a menu will appear. This menu will provide you an opportunity
    to execute this MIRROR operation.

    Type an option at the prompt and press the 'Enter' key.
    Do you wish to continue ['y' (yes) or 'q' (quit/exit PROGRAM)]"

    $answer = Read-Host $prompt

    while (-not ($answer -eq 'y'))
    {
        if ($answer -eq 'q')
        {
            Clear-Host
            Write-Host "`n    ***** Exiting program *****`n"
            exit
        }
        Clear-Host
        $answer = Read-Host $prompt
    }
}

function Show-Menu1 {
    $prompt = Get-Prompt1

    $answer = Read-Host $prompt

    while (-not ($answer -eq 'q'))
    {
        Clear-Host
        switch ($answer) {
            'a' {Print-Paths $g_paths "both" $True}
            'b' {Print-Paths $g_paths "source" $True}
            'c' {Print-Paths $g_paths "target" $True}
            'm' {Robocopy-Dirs $False}
            'o' {Show-Menu2}
            't' {if ($g_runMode -eq 'TEST') {
                     $g_runMode = '!!!!! MIRROR !!!!!'
                     $prompt = Get-Prompt1
                 } else {
                     $g_runMode = 'TEST'
                     $prompt = Get-Prompt1
                 }
                }
        }
        $answer = Read-Host $prompt
    }
    Clear-Host
    Write-Host "`n    ***** Exiting program *****`n"
    exit
}

function Show-Menu2 {
    $prompt = Get-Prompt2
    $answer = Read-Host $prompt

    while (-not ($answer -eq 'p'))
    {
        $showResults = $False
        if ($answer -eq 'q')
        {
            Clear-Host
            Write-Host "`n    ***** Exiting program *****`n"
            exit
        } else {
             Clear-Host
             $pathCount = $g_paths.Count - 1
             switch ($answer) {
                 'a' {Print-Paths $g_paths "both" $True}
                 't' {if ($g_runMode -eq 'TEST') {
                          $g_runMode = '!!!!! MIRROR !!!!!'
                          $prompt = Get-Prompt2
                      } else {
                          $g_runMode = 'TEST'
                          $prompt = Get-Prompt2
                      }
                     }
                 {$_ -in 0..$pathCount} {Robocopy-Dirs $True $_; $showResults = $True}
             }
        }
        $answer = Read-Host $prompt
    }
    Clear-Host
    return
}

## PROMPTS ##
function Get-Prompt1 {
    $prompt = "
    ***** MENU 1 *****
    Enter one of the options below at the prompt, and press Enter.
    View file paths:
    a) View source/target paths.
    b) View source paths.
    c) View target paths.

    m) Mirror ALL source directories to target directories.
    o) Mirror just ONE source path out of all paths (opens another menu).
    t) Toggle 'TEST' and 'MIRROR' mode.

    CURRENT RUN MODE: $g_runMode
    Option prompt ['q' (quit/exit PROGRAM)]"

    return $prompt
}

function Get-Prompt2 {
    $prompt = "
    ***** MENU 2 *****
    a) View source/target paths.

    p) Return to previous menu.
    t) Toggle 'TEST' and 'MIRROR' mode.

    This menu allows you to robocopy ONE source/target path
    combination.

    To MIRROR, enter at the prompt the INDEX NUMBER of ONE of the
    source/target path combinations (listed above) and press Enter.

    CURRENT RUN MODE: $g_runMode
    Option prompt ['q' (quit/exit PROGRAM)]"

    return $prompt
}

## VERIFYING ##
function Verify-Paths {
    # Checks for the existence of directories; and whether the path is
    # malformed.
    $s_ExistsOrMalformed = $g_paths | Where-Object `
      {$_["sourceExists"] -match $False -or $_["sourceIsMalformed"] -match $True}
    $t_ExistsOrMalformed = $g_paths | Where-Object `
      {$_["targetExists"] -match $False -or $_["targetIsMalformed"] -match $True}

    # Test if path is an absolute path. We only deal with absolute paths.
    $t_isAbsolute = $g_paths | Where-Object {-not $([System.IO.Path]::IsPathRooted($_["targetDir"]))}
    $s_isAbsolute = $g_paths | Where-Object {-not $([System.IO.Path]::IsPathRooted($_["sourceDir"]))}

    # Testing for drive-only paths like 'c:\' or 'd:\'; we don't want
    # to MIRROR from one drive into another, without excuding the
    # hidden system directories.
    # This will also test UNC paths; so that we don't mirror from
    # '\\server\share1' to '\\server\share2'.
    $s_isDrive = $g_paths | Where-Object {Test-PathIsDrive $_["sourceDir"]}
    $t_isDrive = $g_paths | Where-Object {Test-PathIsDrive $_["targetDir"]}

    if ($s_ExistsOrMalformed.Count -gt 0)  {
        Write-Host "`nSOURCE paths that are MALFORMED or do NOT EXIST."
        Print-Paths -pathHash $s_ExistsOrMalformed -pathType "source" -onlyPath $False
    }

    if ($t_ExistsOrMalformed.Count -gt 0)  {
        Write-Host "`nTARGET paths that are MALFORMED or do NOT EXIST."
        Print-Paths -pathHash $t_ExistsOrMalformed -pathType "target" -onlyPath $False
    }

    if ($s_isAbsolute.Count -gt 0) {
        Write-Host "`nSOURCE paths that are not ABSOLUTE paths."
        Print-Paths -pathHash $s_isAbsolute -pathType "source" -onlyPath $False
    }

    if ($t_isAbsolute.Count -gt 0) {
        Write-Host "`nTARGET paths that are not ABSOLUTE paths."
        Print-Paths -pathHash $t_isAbsolute -pathType "target" -onlyPath $False
    }

    if ($s_isDrive.Count -gt 0) {
        Write-Host "`nSOURCE paths that are DRIVES or RELATIVE."
        Write-Host "Or UNC paths are of the form '\\<server name><share name>'."
        Print-Paths -pathHash $s_isDrive -pathType "source" -onlyPath $False
    }

    if ($t_isDrive.Count -gt 0) {
        Write-Host "`nTARGET paths that are DRIVES or RELATIVE."
        Write-Host "Or UNC paths are of the form '\\<server name><share name>'."
        Print-Paths -pathHash $t_isDrive -pathType "target" -onlyPath $False
    }

    if ($s_ExistsOrMalformed.Count -gt 0 -or $t_ExistsOrMalformed.Count -gt 0 -or
        $s_isDrive.Count -gt 0 -or $t_isDrive.Count -gt 0 -or
        $s_isAbsolute.Count -gt 0 -or $t_isAbsolute.Count -gt 0) {
    "
    The above lists may contain directory paths that
    - are either MALFORMED or DO NOT EXIST.
    - are only DRIVES or RELATIVE paths. Or UNC paths are of the form
      '\\<server name><share name>'. None are allowed.
      - Mirrors can only be made into sub-directories. Not drive to
        a drive or a server share.
      - This way we don't have to exclude hidden system directories.
    This program will not run unless these paths are
    fixed. NOTE: Only absolute paths are allowed.
    "
    Exit-Program
    }
}

# This works for paths like 'c:\'.
# It also works for UNC paths, if the '\\<server>\<share>' is specified.
function Test-PathIsDrive ($path) {
    $parent = Split-Path $path -Parent
    return $parent -eq ''
}

## PRINTING ##
# - $pathHash: an array of path hashes.
# - $pathType: 'source', 'target', or 'both'
# - $onlyPath: print only the paths? If 'False', include the "exists"
#   and "malformed" information.
function Print-Paths {
    param ($pathHash,
           $pathType,
           $onlyPath)

    $index = 0
    foreach ($h in $pathHash) {
        $sourceDir = $h["sourceDir"]
        $sourceExists = $h["sourceExists"]
        $sourceIsMalformed = $h["sourceIsMalformed"]
        $targetDir = $h["targetDir"]
        $targetExists = $h["targetExists"]
        $targetIsMalformed = $h["targetIsMalformed"]

        if ($pathType -eq "source") {
            if ($onlyPath) {
                Write-Host $("[$index] SOURCE: $sourceDir")
            }
            else {
                Write-Host $("[$index] SOURCE: [Exists = $sourceExists]" + `
                  " [Malformed = $sourceIsMalformed]`n" + `
                  "[$index] SOURCE: $sourceDir")
            }
        } elseif ($pathType -eq "target") {
            if ($onlyPath) {
                Write-Host $("[$index] TARGET: $targetDir")
            }
            else {
                Write-Host $("[$index] TARGET: [Exists = $targetExists]" + `
                  " [Malformed = $targetIsMalformed]`n" + `
                  "[$index] TARGET: $targetDir")
            }
        } elseif ($pathType -eq "both") {
            if ($onlyPath) {
                Write-Host $("[$index] SOURCE: $sourceDir")
                Write-Host $("[$index] TARGET: $targetDir`n")
            }
            else {
                Write-Host $("[$index] SOURCE: [Exists = $sourceExists]" + `
                  " [Malformed = $sourceIsMalformed]")
                Write-Host $("[$index] TARGET: [Exists = $targetExists]" + `
                  " [Malformed = $targetIsMalformed]")
                Write-Host $("[$index] SOURCE: $sourceDir")
                Write-Host $("[$index] TARGET: $targetDir`n")
            }
        }
        ++$index
    }
}

## ROBOCOPY ##
function Robocopy-Dirs {
    param ([boolean]$copyOnlyOne,
           [int]$arrayIndex)

    $loopArray = @()

    # If mirroring only one source/target path combination, loop only
    # once with an array of one specific hash.
    if ($copyOnlyOne) {
        $loopArray += $g_paths[$arrayIndex]
        $index = $arrayIndex
    }
    else {
        $loopArray = $g_paths
        $index = 0
    }
    foreach ($d in $loopArray) {
        $s = $d["sourceDir"]
        $t = $d["targetDir"]

        $tDirName = ($(Split-Path $t -Leaf) + '_' + $(Get-LogDateTime))

        Write-Host "
Copying in mode: $g_runMode
[$index] SOURCE: $s
[$index] TARGET: $t"

        if ($g_runMode -eq 'TEST') {
            $script = "robocopy  `"$s`" `"$t`" /L /R:1 /W:1 /MIR /NP /DCOPY:T /LOG:$robocopy_log_dir\`"$tDirname`"_test.log"
        } else {
            $script = "robocopy  `"$s`" `"$t`" /R:1 /W:1 /MIR /NP /DCOPY:T /LOG:$robocopy_log_dir\`"$tDirname`"_mirror.log"
        }

        Invoke-Expression $script

        $exitCode = Get-RcopyExitMsg $LASTEXITCODE
	Write-Host "Exit code [$LASTEXITCODE]:`n$exitCode"
        $index++
     }
}

# According to https://ss64.com/nt/robocopy-exit.html:
#  "An Exit Code of 0-7 is success and any value >= 8 indicates that
#  there was at least one failure during the copy operation."
# Miscellaneous robocopy return codes gathered from the internet:
# 0 No errors occurred, and no copying was done. The source
#   and destination directory trees are completely
#   synchronized.
# 1 One or more files were copied successfully (that is, new
#   files have arrived).
# 2 Some Extra files or directories were detected. Examine
#   the output log. Some housekeeping may be needed.
# 3 Some files were copied. Additional files were present. No
#   failure was met.
# 4 Some Mismatched files or directories were detected.
#   Examine the output log. Housekeeping is probably
#   necessary.
# 5 Some files were copied. Some files were mismatched. No
#   failure was met.
# 6 Additional files and mismatched files exist. No files
#   were copied and no failures were met. Which means that the
#   files already exist in the destination directory.
# 7 Files were copied, a file mismatch was present, and
#   additional files were present.
# 8 Some files or directories could not be copied (copy
#   errors occurred and the retry limit was exceeded). Check
#   these errors further.
# 10 Serious error. Robocopy did not copy any files. This is
#   either a usage error or an error due to insufficient access
#   privileges on the source or destination directories.
# 16 Serious error. Robocopy did not copy any files.
#   Either a usage error or an error due to insufficient
#   access privileges on the source or destination
#   directories.
function Get-RcopyExitMsg ($exitCode) {
    switch($exitCode) {
        {$_ -in 0..7} {return "Successful."}
        default {return "At least one failure occured. See log for more details."}
    }
}

function Get-LogDateTime {
    return (Get-Date).ToString('s').Replace(':','.')
}

function Get-DirSubPaths  {
    param ($file_path)

    return @(Get-Content -Path $file_path | ConvertFrom-csv)
}

# Construct-PathDict
# PURPOSE: Takes an array of paths; in this case, an array of
# 'PSCustomObject's (as generated by 'ConvertFrom-Json'). Each object
# has the properties 'sourceDir' and 'targetDir'. It iterates through
# this array and returns a new array of hashes. These hashes include
# extra keys ('sourceExists', 'sourceIsMalformed', 'targetExists',
# 'targetIsMalformed').
function Construct-PathHash ($path_array) {
    $hash = @{}
    $hash_array = @()

    foreach ($p in $path_array) {
        $sourceDir = $p.source_dir
        $targetDir = $p.target_dir

        $hash = [ordered]@{"sourceDir" = $sourceDir
                           "sourceExists" = Test-PathIsDir $sourceDir
                           "sourceIsMalformed" = -not $(Test-Path $sourceDir -IsValid)
                           "targetDir" = $targetDir
                           "targetExists" = Test-PathIsDir $targetDir
                           "targetIsMalformed" = -not $(Test-Path $targetDir -IsValid)}

        $hash_array += $hash
    }
    return $hash_array
}

function Test-PathIsDir {
    param ($dirPath)

    # A UNC path will fail with the error
    # 'The network path was not found'
    # if the directory does not exist.
    # Return 'False' if there is an error of any kind.
    try {
        return Test-Path $dirPath -PathType Container
    }
    catch {
        return $False
    }
}

function Exit-Program {
    Read-Host "`n***** Exiting program *****`n`nPress ENTER exit"
    exit
}

function Start-Main () {
    try {
        $csv_file_exists = Test-Path $csv_dir_list_file
        $log_dir_exists = Test-Path $robocopy_log_dir

        if ($csv_file_exists -and $log_dir_exists) {
            Clear-Host
            Show-Menu0

            # By default this program will do MIRROR operations in TEST-mode; the
            # user has to explicitly tell the program to run in MIRROR-mode.
            $g_runMode = 'TEST'

            $g_paths = @()
            $paths = Construct-PathHash $(Get-DirSubPaths $csv_dir_list_file)

            if ($paths -ne $null) {
                # Apparently, if 'Construct-PathHash' creates an array of
                # one hash, then it only returns the hash. So, we have to
                # recreate the array of one hash.
                if ($paths.GetType().Name -eq 'OrderedDictionary') {
                    $g_paths += $paths
                }
                else {
                    $g_paths = $paths
                }
            } else {
                Write-Host "`nThe CSV file does not have any paths."
                Exit-Program
            }

            Verify-Paths

            Clear-Host
            Show-Menu1
        } else
        {
            if (-not $csv_file_exists) {
                Write-Host "
The CSV file:
$csv_dir_list_file
does not exist.`n"

'Please correct the path passed to the $csv_dir_list_file parameter.'
                Exit-Program
            }
            if (-not $log_dir_exists) {
                Write-Host "
The robocopy log diretory:
$robocopy_log_dir
does not exist.`n"

'Please correct the path passed to the $robocopy_log_dir parameter.'
                Exit-Program
            }
        }
    }
    catch {
        Write-Host "Error: $_"
    }
}

Start-Main
