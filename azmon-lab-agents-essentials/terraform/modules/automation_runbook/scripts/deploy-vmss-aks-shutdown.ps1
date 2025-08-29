param(
        [Parameter(Mandatory=$true)]
        [string]$resourcegroupname,
        
        [Parameter(Mandatory=$true)]
        [string]$vmssname,
        
        [Parameter(Mandatory=$true)]
        [string]$subscriptionid,
        
        [Parameter(Mandatory=$true)]
        [string]$aksname
    )

    # Function to ensure Az modules are available
    function Ensure-AzModules {
        try {
            Write-Output "Checking for required Az modules..."
            
            # Import modules if available, otherwise they'll be auto-installed on first use
            if (Get-Module -ListAvailable -Name Az.Accounts) {
                Import-Module Az.Accounts -Force
                Write-Output "Az.Accounts module imported"
            }
            
            if (Get-Module -ListAvailable -Name Az.Compute) {
                Import-Module Az.Compute -Force  
                Write-Output "Az.Compute module imported"
            }
            
            if (Get-Module -ListAvailable -Name Az.Aks) {
                Import-Module Az.Aks -Force  
                Write-Output "Az.Aks module imported"
            }
        }
        catch {
            Write-Output "Modules will be auto-installed on first use: $($_.Exception.Message)"
        }
    }

    # Ensure modules are available
    Ensure-AzModules

    # Connect using managed identity
    try {
        Write-Output "Connecting to Azure using Managed Identity..."
        Connect-AzAccount -Identity
        Set-AzContext -SubscriptionId $subscriptionid
        Write-Output "Successfully connected to Azure"
    }
    catch {
        Write-Error "Failed to connect to Azure: $($_.Exception.Message)"
        exit 1
    }

    # Stop the VMSS
    try {
        Write-Output "Stopping VMSS: $vmssname in Resource Group: $resourcegroupname"
        
        # Get the VMSS
        $vmss = Get-AzVmss -ResourceGroupName $resourcegroupname -VMScaleSetName $vmssname
        
        if ($vmss) {
            Write-Output "Found VMSS with $($vmss.Sku.Capacity) instances"
            
            # Stop all instances in the VMSS
            Stop-AzVmss -ResourceGroupName $resourcegroupname -VMScaleSetName $vmssname -Force
            
            Write-Output "Successfully initiated shutdown of VMSS: $vmssname"
        }
        else {
            Write-Warning "VMSS $vmssname not found in Resource Group $resourcegroupname"
        }
    }
    catch {
        Write-Error "Failed to stop VMSS: $($_.Exception.Message)"
        # Don't exit here, continue to try AKS shutdown
    }

    # Stop the AKS cluster
    try {
        Write-Output "Stopping AKS cluster: $aksname in Resource Group: $resourcegroupname"
        
        # Get the current state of the AKS cluster
        $aks = Get-AzAksCluster -ResourceGroupName $resourcegroupname -Name $aksname
        
        if ($aks) {
            if ($aks.PowerState.Code -eq "Running") {
                Write-Output "AKS cluster '$aksname' is currently running. Stopping it..."
                Stop-AzAksCluster -ResourceGroupName $resourcegroupname -Name $aksname
                Write-Output "Successfully initiated shutdown of AKS cluster: $aksname"
            }
            elseif ($aks.PowerState.Code -eq "Stopped") {
                Write-Output "AKS cluster '$aksname' is already stopped."
            }
            else {
                Write-Output "AKS cluster '$aksname' is in an unknown state: $($aks.PowerState.Code)"
            }
        }
        else {
            Write-Warning "AKS cluster $aksname not found in Resource Group $resourcegroupname"
        }
    }
    catch {
        Write-Error "Failed to stop AKS cluster: $($_.Exception.Message)"
        # Don't exit here, log the error but complete the runbook
    }

    Write-Output "Runbook execution completed successfully"