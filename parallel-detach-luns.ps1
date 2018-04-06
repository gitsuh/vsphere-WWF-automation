Workflow detachluns {
	param
		(
			[string]$vcenter,
			[string]$session,
			$vmhosts,
			[string]$naaid
		)
	foreach -parallel($vmhost in $vmhosts){
		$result = InlineScript{
				Import-Module VMware.VimAutomation.Core
				Connect-VIServer -Server $Using:vcenter -Session $Using:session | Out-Null
				$vmh = get-vmhost $Using:vmhost
				$scsiluns = $vmh |get-scsilun
				foreach($scsilun in $scsiluns){
					if($scsilun.canonicalname -eq $Using:naaid){
						$lunid = $scsilun.extensiondata.uuid
						$storsys = get-view $vmh.Extensiondata.Configmanager.storagesystem
						$storsys.DetachScsiLun($lunid);
					}
				}
		}
	}
}
$mycluster = "CLUSTERNAME"
$myvmhosts = get-cluster $mycluster | get-vmhost | where {$_.ConnectionState  -eq "Connected" -and $_.PowerState -eq "PoweredOn"}
$naalist =@(
"CANONICALNAME",
"CANONICALNAME2"
)
foreach($mynaaid in $naalist){
	detachluns -vmhosts $myvmhosts -naaid $mynaaid -vcenter $global:DefaultVIServer.Name -session $global:DefaultVIServer.SessionSecret
}
