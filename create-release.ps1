# Define the path to the project.godot file
$projectFilePath = "project.godot"

# Define the path to the release notes file
$releaseNotesFilePath = "release_notes.md"

# Read the lines from the project.godot file
$fileContent = Get-Content $projectFilePath

# Find the line that contains the version information
$versionLine = $fileContent | Where-Object { $_ -match 'config/version="(\d+\.\d+\.\d+\.\d+)"' }

# Extract the version number from the line
if ($versionLine -match 'config/version="(\d+\.\d+\.\d+\.\d+)"') {
    $version = $matches[1]
    Write-Output "Version found: $version"

    # Define the Git commands
    $tagCommand = "git tag -a $version -m 'Release $version'"
    $pushTagsCommand = "git push --tags"

    # Read the custom release notes from the file
    $releaseNotes = Get-Content $releaseNotesFilePath -Raw

    # Save the release notes to a temporary file (if needed)
    $tempReleaseNotesFile = "temp_release_notes_$version.md"
    $releaseNotes | Set-Content $tempReleaseNotesFile

    # GitHub CLI command to create a release with custom release notes
    $releaseCommand = "gh release create $version --notes-file $tempReleaseNotesFile"

    # Execute the Git commands
    Invoke-Expression $tagCommand
    Invoke-Expression $pushTagsCommand
    Invoke-Expression $releaseCommand

    Write-Output "Release $version created successfully with custom release notes."
} else {
    Write-Output "Version not found in the project.godot file."
}
