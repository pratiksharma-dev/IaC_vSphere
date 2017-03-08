$json = (Get-Content ..\Json\Template.json | Out-String) 
Add-Type -Path "..\JsonDeserializer\JsonDeserializer\bin\Debug\JsonDeserializer.dll"
$template=[JsonDeserializer.Jsontool]::Deseerializer($json)
Add-PsSnapin VMware.VimAutomation.Core
foreach($res in $template.resources)
{
switch($res.type)
{
"VirtualMachines" {Deploy-VM -Name $res.name -vm $res.properties -mode $res.mode ;break}
default {"Invalid resource type"}
}
}





