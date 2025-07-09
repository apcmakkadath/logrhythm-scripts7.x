Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global form and textboxes
$form = $null
$dsnBox = $null
$userBox = $null
$passBox = $null
$connBox = $null
$queryBox = $null

function createForm {
    $global:form = New-Object System.Windows.Forms.Form
    $form.Text = "Database Connection"
    $form.Size = New-Object System.Drawing.Size(600, 350)
    $form.StartPosition = "CenterScreen"
}

function Add-LabelTextboxPair {
    param (
        [string]$labelText,
        [int]$top,
        [bool]$isPassword = $false
    )

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $labelText
    $label.Location = New-Object System.Drawing.Point(10, $top)
    $label.Size = New-Object System.Drawing.Size(130, 40)
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($label)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point(150, $top)
    $textbox.Size = New-Object System.Drawing.Size(390, 40)
    $textbox.Font = New-Object System.Drawing.Font("Segoe UI", 12)
    if ($isPassword) { $textbox.UseSystemPasswordChar = $true }
    $form.Controls.Add($textbox)

    return $textbox
}

function addFields {
    $global:dsnBox = Add-LabelTextboxPair "DSN:" 20
    $global:userBox = Add-LabelTextboxPair "Username:" 60
    $global:passBox = Add-LabelTextboxPair "Password:" 100 $true
    $global:connBox = Add-LabelTextboxPair "Connection String:" 140
    $global:queryBox = Add-LabelTextboxPair "Query:" 180
}

function runOrCancel {
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "Run"
    $okButton.Location = New-Object System.Drawing.Point(140, 230)
    $okButton.Add_Click({
        $global:dsn = $dsnBox.Text
        $global:user = $userBox.Text
        $global:pass = $passBox.Text
        $global:conn = $connBox.Text
        $global:query = $queryBox.Text
        runQuery
    })
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object System.Drawing.Point(240, 230)
    $cancelButton.Add_Click({ $form.Close() })
    $form.Controls.Add($cancelButton)
}

function showForm {
    $form.Topmost = $true
    $form.Add_Shown({ $form.Activate() })
    [void]$form.ShowDialog()
}

function runQuery {
    $connection = New-Object System.Data.Odbc.OdbcConnection($conn)
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    $columnCount = $reader.FieldCount

    $results = @()

    while ($reader.Read()) {
        $lineParts = @()
        for ($i = 0; $i -lt $columnCount; $i++) {
            $columnName = $reader.GetName($i)
            $value = $reader.GetValue($i)
            $lineParts += "$columnName=$value"
        }
        $results += ($lineParts -join ", ")
    }

    $reader.Close()
    $connection.Close()

    if ($results.Count -gt 0) {
        $output = $results -join "`n"
        [System.Windows.Forms.MessageBox]::Show($output, "Query Results")
    } else {
        [System.Windows.Forms.MessageBox]::Show("No results returned.", "Query Results")
    }
}


# Main
createForm
addFields
runOrCancel
showForm
