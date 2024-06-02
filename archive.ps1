###################################################
# Complementary module for archive solve projects #
###################################################

# add a file to archive and remove it
function Push-Archive {
	param (
		`$filename = `$null
	)
	`$filename = `$(Get-Filename `$filename)
	if (Test-Path -Path ".\`$filename" -PathType Leaf) {
		if (Test-Path -Path ".\archive" -PathType Container) { 
			Clear-Host 
		}
		else { 
			New-Item -ItemType Directory -Path ".\archive" | Out-Null 
		}
		Copy-Item ".\`$filename" -Destination ".\archive\`$filename"
		Remove-Item ".\`$filename"
		Write-Host "The project was perfectly archived !" -ForegroundColor Green
	}
	else {
		Write-Host "The project don't exist !" -ForegroundColor Red
	}
}
Set-Alias -Name archive -Value Push-Archive

# copy file in file directory + pop file from archive
function Pop-Archive {
	param (
		`$filename = `$null
	)
	`$filename = `$(Get-Filename `$filename)
	
	if (Test-Path -Path ".\archive\`$filename" -PathType Leaf) {
		Copy-Item ".\archive\`$filename" -Destination "."
		Remove-Item ".\archive\`$filename"
		`$(code ".\`$filename")
		Write-Host "The project was perfectly un-archived !" -ForegroundColor Green
	}
	else {
		Write-Host "The project don't exist !" -ForegroundColor Red
	}
}
Set-Alias -Name un-archive -Value Pop-Archive

# get archive directories
function Get-Archive-Directories {
	param(
		`$current_path
	)
	if (`$current_path -match "C:\\(?<path>.*)\\archive") {
		return @(`$current_path);
	}
	else {
		`$return = @();
		foreach (`$directories in `$(Get-ChildItem `$current_path -Directory)) {
			`$return += `$(Get-Archive-Directories "`$current_path\`$directories");
		}
		return `$return;
	}
}

# delete files archived 15 days ago
function Remove-Old-Archived-Files {
	`$paths = `$(Get-Archive-Directories $HOME);
	foreach (`$path in `$paths) {
		`$limit = (Get-Date).AddDays(-15)

		# Delete files older than the `$limit.
		Get-ChildItem -Path `$path -Recurse -Force | Where-Object { !`$_.PSIsContainer -and `$_.CreationTime -lt `$limit } | Remove-Item -Force

		# Delete any empty directories left behind after deleting the old files.
		Get-ChildItem -Path `$path -Recurse -Force | Where-Object { `$_.PSIsContainer -and `$null -eq (Get-ChildItem -Path `$_.FullName -Recurse -Force | Where-Object { !`$_.PSIsContainer }) } | Remove-Item -Force -Recurse
	}
}

Remove-Old-Archived-Files
