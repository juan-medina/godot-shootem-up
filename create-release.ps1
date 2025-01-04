# Define the path to the project.godot file
$projectFilePath = "project.godot"

# Read the lines from the file
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
    $releaseCommand = "gh release create $version --notes-file release_notes.md"

    # Execute the Git commands
    Invoke-Expression $tagCommand
    Invoke-Expression $pushTagsCommand
    Invoke-Expression $releaseCommand

    Write-Output "Release $version created successfully."
} else {
    Write-Output "Version not found in the project.godot file."
}