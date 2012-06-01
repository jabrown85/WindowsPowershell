@{
ModuleVersion="0.0.0.1"
Description="A Wrapper for Microsoft's SQL Server PowerShell Extensions Snapins"
Author="Chad Miller"
Copyright="© 2010, Chad Miller, released under the Ms-PL"
CompanyName="http://sev17.com"
CLRVersion="2.0"
FormatsToProcess="SQLProvider.Format.ps1xml"
NestedModules="Microsoft.SqlServer.Management.PSSnapins.dll","Microsoft.SqlServer.Management.PSProvider.dll"
RequiredAssemblies="Microsoft.SqlServer.Smo","Microsoft.SqlServer.Dmf","Microsoft.SqlServer.SqlWmiManagement","Microsoft.SqlServer.ConnectionInfo","Microsoft.SqlServer.SmoExtended","Microsoft.SqlServer.Management.RegisteredServers","Microsoft.SqlServer.Management.Sdk.Sfc","Microsoft.SqlServer.SqlEnum","Microsoft.SqlServer.RegSvrEnum","Microsoft.SqlServer.WmiEnum","Microsoft.SqlServer.ServiceBrokerEnum","Microsoft.SqlServer.ConnectionInfoExtended","Microsoft.SqlServer.Management.Collector","Microsoft.SqlServer.Management.CollectorEnum"
TypesToProcess="SQLProvider.Types.ps1xml"
ScriptsToProcess="Sqlps.ps1"
}

