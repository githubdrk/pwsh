# Step 3: Retrieve the Secret (it will be in SecureString format)
$secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName

# Step 4: Convert the SecureString to Plain Text
# SecureString to plain text conversion
$plainSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue))

# Step 5: Output the Plain Secret
Write-Output $plainSecret
