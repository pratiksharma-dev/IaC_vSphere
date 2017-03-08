Function Deploy-VM {
[cmdletbinding()]
Param (
[Parameter(Mandatory=$true)]
$Name,
[Parameter(Mandatory=$true)]
$vm,
$mode 
   ) 
$ErrorActionPreference = "Stop"
$vm=$res.properties
$Name=$res.name
$mode=$res.mode
if([string]::IsNullOrWhiteSpace($mode)){$mode="create"}

if([string]::IsNullOrWhiteSpace($vm.vcentercredential.username)){$vm.vcentercredential.username="<vcenter username>";$vm.vcentercredential.password="<vcenter password>"}

if([string]::IsNullOrWhiteSpace($vm.vcenterserver)){$vm.vcenterserver="<vcenterfqdn>"}

Connect-VIServer -Server $vm.vcenterserver -User $vm.vcentercredential.username -Password $vm.vcentercredential.password -Verbose

if([string]::IsNullOrWhiteSpace($vm.template)){$vm.template = "<template>"}

if([string]::IsNullOrWhiteSpace($vm.datacenter)){$vm.datacenter ="<datacenter>"}

if([string]::IsNullOrWhiteSpace($vm.cluster)){$vm.cluster="<cluster>"}

if([string]::IsNullOrWhiteSpace($vm.vmhost)){$vm.vmhost=(Get-VMHost -Location $vm.cluster -State Connected|Sort-Object MemoryUsageGB)[0]}

if([string]::IsNullOrWhiteSpace($vm.datastore)){$vm.datastore=(Get-Datastore -Location $vm.datacenter |Where {$_.State -eq "Available"}|Sort FreeSpaceGB -Descending)[0]}

if([string]::IsNullOrWhiteSpace($vm.environment)){$vm.environment="TRN"}

if($vm.rebootforEdit -eq $null){$vm.rebootforEdit =$false}

if([string]::IsNullOrWhiteSpace($vm.Customizationspecs)){$vm.Customizationspecs="$($vm.environment)_Spec"}

if((-Not [string]::IsNullOrWhiteSpace($vm.dscpullserver.pullserverurl)) -and ($vm.dscpullserver.pullserverurl -ne "RegistrationUrl") -and (-Not [string]::IsNullOrWhiteSpace($vm.dscpullserver.registrationkey))){
#Pending
}

if((Get-VM -Name $Name -Location $vm.cluster -ErrorAction SilentlyContinue) -ne $null) {

if($mode -eq "create"){
Write-Error "VM with name $Name already exists, if you want to edit the vm kindly set mode to 'edit'"}
 }
 else
 {
 New-VM -Name $Name -Template $vm.template -OSCustomizationSpec $vm.Customizationspecs -VMHost $vm.vmhost -Datastore $vm.datastore -Location $vm.cluster
 }
$vmstate=Get-VM -Name PoshOriginVM -Location $vm.cluster |Get-View
if(-Not $vm.rebootforEdit){

if(($vm.vcpu -ne $null) -and ($vm.vcpu -ne $vmstate.Config.Hardware.NumCPU ){

if($vmstate.Runtime.PowerState -eq "poweredOn"){

if(-Not $vmstate.Config.cpuHotAddEnabled)
{
Write-Error "vCPU for $Name cannot be edited when it is in 'PoweredOn' state. CPU and Memory edits requires reboot, kindly set 'rebootforEdit' property to true or set 'enableCPUHotAdd' to true, after setting 'enableCPUHotAdd' you will still be required to reboot once hence set 'rebootforEdit' true but all subsequent vCPU edits can be without reboot"
return
}
}
 $spec = New-Object -TypeName Vmware.Vim.VirtualMachineConfigSpec -Property @{
            "NumCoresPerSocket" = $vm.corespersocket
            "NumCPUs" = $vm.vcpu
}
  $vm.extensiondata.reconfigvm_task($spec)

}
}
}
