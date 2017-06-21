# URL Example:  "https://images-api.nasa.gov/search?q=orion&description=nebula&media_type=image"
# BASE URL: "https://images-api.nasa.gov/search"
# Query: ?q=<String>
# Description: &description=<string>
# Media_type: media_type=<string>

Write-Host "`r`nOnly one search element is needed to return data.`r`n"

$URL = "https://images-api.nasa.gov/search?"

$object = Read-Host "Object"
$desc = Read-Host "Description"

# Horrid way to build the URL
if ($object -and $desc) {
    $URL += "q=" + $object + "&description=" + $desc
}
elseif ($object) {
    $URL += "q=" + $object
}
elseif ($desc) {
    $URL += "description=" + $desc
}

$URL

# Getting data
$data = Invoke-RestMethod $URL

# Search results
Write-Host "`r`nWe found $($data.collection.metadata.total_hits) results`r`n" -ForegroundColor Red
Write-Host "Gathering Data... " -ForegroundColor Red

$imgURL = @()
$objDesc = @()
$objTitle = @()


foreach ($item in $data.collection.items) {
    foreach ($json in $item.href) {
        $temp = Invoke-RestMethod $json
        $imgURL += $temp[0]
    }

    $objDesc += $item.data.description

    $objTitle += $item.data.title

}

##################################################### START OF GUI #########################################################
$itemIndex = 0

function makeForm() {
    $itemIndex
    Add-Type -AssemblyName System.Windows.Forms


    $Viewer = New-Object system.Windows.Forms.Form
    $Viewer.Text = $objTitle[$itemIndex]
    $Viewer.BackColor = "#abaaaa"
    $Viewer.TopMost = $true
    $Viewer.Width = 1024
    $Viewer.Height = 768


    $Description = New-Object system.windows.Forms.TextBox
    $Description.Multiline = $true
    $Description.Width = 984
    $Description.Height = 145
    $Description.location = new-object system.drawing.point(8, 567)
    $Description.Font = "Consolas,10"
    $Description.Text = $objDesc[$itemIndex]
    $Viewer.controls.Add($Description)


    $Images = New-Object system.windows.Forms.PictureBox
    $Images.Width = 984
    $Images.Height = 472
    $Images.Width = 984
    $Images.Height = 472
    $Images.location = new-object system.drawing.point(9, 10)
    $Images.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $Images.load($imgURL[$itemIndex])
    $Viewer.controls.Add($Images)


    $Back = New-Object system.windows.Forms.Button
    $Back.Text = "Back"
    $Back.Width = 156
    $Back.Height = 56
    $Back.location = new-object system.drawing.point(3, 497)
    $Back.Font = "Consolas,10"
    $Viewer.controls.Add($Back)


    $Next = New-Object system.windows.Forms.Button
    $Next.Text = "Next"
    $Next.Width = 155
    $Next.Height = 59
    $Next.location = new-object system.drawing.point(171, 497)
    $Next.Font = "Consolas,10"
    $Viewer.controls.Add($Next)
    $Next.Add_Click({
        $script:itemIndex += 1
        $Description.Text = $script:objDesc[$itemIndex]
        $Images.Load($imgURL[$itemIndex])
    })


    [void]$Viewer.ShowDialog()
    $Viewer.Dispose()
}

makeForm