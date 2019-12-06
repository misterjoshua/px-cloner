param(
  # Source namespace
  [Parameter(Position=0)]
  [String]
  $SourceNamespace,

  # Destination namespace
  [Parameter(Position=1)]
  [String]
  $DestinationNamespace,

  [Parameter()]
  [switch]
  $Version
)

function Test-Commands {
  kubectl version >$null 2>$null
}

function New-ApplicationClone {
  $nowEpochFormat = (Get-Date -UFormat "%s") -Split "\." | Select-Object -First 1
  $cloneName = "clone-$SourceNamespace-to-$DestinationNamespace-$nowEpochFormat"

  $config = @"
apiVersion: stork.libopenstorage.org/v1alpha1
kind: ApplicationClone
metadata:
    name: $cloneName
    namespace: kube-system
spec:
    sourceNamespace: $SourceNamespace
    destinationNamespace: $DestinationNamespace
    replacePolicy: Delete
"@

  Write-Host "Submitting ApplicationClone request."
  $config | kubectl -n kube-system apply -f-

  $delay = 1
  $stage = ""
  while ($stage -notlike "Final") {
      Start-Sleep -Seconds $delay
      $stage = kubectl -n kube-system get applicationclone $cloneName -o jsonpath="{ .status.stage }"
      Write-Host "Application clone stage: $stage"
  }

  Write-Host "Restarting pods"
  kubectl -n $DestinationNamespace delete pods --all
}

#######
# Script begins
########

$ErrorActionPreference = "Stop"

if ($Version) {
  Write-Host "%%VERSION%%"
} else {
  if (-not $SourceNamespace) { throw "Missing SourceNamespace" }
  if (-not $DestinationNamespace) { throw "Missing DestinationNamespace" }
  if ($SourceNamespace -like $DestinationNamespace) { throw "SourceNamespace and DestinatioNamespace are the same" }

  Test-Commands
  New-ApplicationClone
}
