Configure your Azure Stack HCI 20H2 Cluster
==============
Overview
-----------

So far, you've deployed your Azure VM, that has all the relevant roles and features enabled, including Hyper-V, AD Domain Services, DNS and DHCP. The VM deployment also orchestrated the download of all required binaries, as well as creating and deploying 2 Azure Stack HCI 20H2 nodes, which you'll be configuring in this step.

Contents
-----------
- [Overview](#overview)
- [Contents](#contents)
- [Architecture](#architecture)
- [Before you begin](#before-you-begin)
- [Creating a (local) cluster](#creating-a-local-cluster)
- [Configuring the cluster witness](#configuring-the-cluster-witness)
- [Connect and Register Azure Stack HCI 20H2 to Azure](#connect-and-register-azure-stack-hci-20h2-to-azure)
- [Next Steps](#next-steps)
- [Product improvements](#product-improvements)
- [Raising issues](#raising-issues)

Architecture
-----------

As shown on the architecture graphic below, in this step, you'll take the nodes that were previously deployed, and be **clustering them into an Azure Stack HCI 20H2 cluster**. You'll be focused on **creating a cluster in a single site**.

![Architecture diagram for Azure Stack HCI 20H2 nested](/media/nested_virt_nodes_ga.png "Architecture diagram for Azure Stack HCI 20H2 nested")

Before you begin
-----------
With Windows Admin Center, you now have the ability to construct Azure Stack HCI 20H2 clusters from the vanilla nodes.  There are no additional extensions to install, the workflow is built in and ready to go.

Here are the major steps in the Create Cluster wizard in Windows Admin Center:

* **Get Started** - ensures that each server meets the prerequisites for and features needed for cluster join
* **Networking** - assigns and configures network adapters and creates the virtual switches for each server
* **Clustering** - validates the cluster is set up correctly. For stretched clusters, also sets up up the two sites
* **Storage** - Configures Storage Spaces Direct

### Decide on cluster type ###
Not only does Azure Stack HCI 20H2 support a cluster in a single site (or a **local cluster** as we'll refer to it going forward) consisting of between 2 and 16 nodes, but, also supports a **Stretch Cluster**, where a single cluster can have nodes distrubuted across two sites.

* If you have 2 Azure Stack HCI 20H2 nodes, you will be able to create a **local cluster**
* If you have 4 Azure Stack HCI 20H2 nodes, you will have a choice of creating either a **local cluster** or a **stretch cluster**

In this workshop, we'll be focusing on deploying a **local cluster** but if you're interested in deploying a stretch cluster, you can [check out the official docs](https://docs.microsoft.com/en-us/azure-stack/hci/concepts/stretched-clusters "Stretched clusters overview on Microsoft Docs")

Creating a (local) cluster
-----------
This section will walk through the key steps for you to set up the Azure Stack HCI 20H2 cluster with the Windows Admin Center

1. Connect to your **HybridHost001**, and open **Windows Admin Center** using the shortcut on your desktop.
2. Once logged into Windows Admin Center, under **All connections**, click **Add**
3. On the **Add or create resources popup**, under **Server clusters**, click **Create new** to open the **Cluster Creation wizard**

### Get started ###

![Choose cluster type in the Create Cluster wizard](/media/wac_cluster_type_ga.png "Choose cluster type in the Create Cluster wizard")

1. Ensure you select **Azure Stack HCI**, select **All servers in one site** and cick **Create**
2. On the **Check the prerequisites** page, review the requirements and click **Next**
3. On the **Add Servers** page, supply a **username**, which should be **hybrid\azureuser** and **password-you-used-at-VM-deployment-time** and then one by one, enter the node names of your Azure Stack HCI 20H2 nodes (AZSHCINODE01 and AZSHCINODE02), clicking **Add** after each one has been located.  Each node will be validated, and given a **Ready** status when fully validated.  This may take a few moments - once you've added all nodes, click **Next**

![Add servers in the Create Cluster wizard](/media/add_nodes_ga.png "Add servers in the Create Cluster wizard")

4. On the **Join a domain** page, details should already be in place, as these nodes have already been joined to the domain to save time. If this wasn't the case, WAC would be able to configure this for you. Click **Next**

![Joined the domain in the Create Cluster wizard](/media/wac_domain_joined_ga.png "Joined the domain in the Create Cluster wizard")

1. On the **Install features** page, Windows Admin Center will query the nodes for currently installed features, and will typically request you install required features. In this case, all features have been previously installed to save time, as this would take a few moments. Once reviewed, click **Next**

![Installing required features in the Create Cluster wizard](/media/wac_installed_features_ga.png "Installing required features in the Create Cluster wizard")

6. On the **Install updates** page, Windows Admin Center will query the nodes for available updates, and will request you install any that are required. For the purpose of this guide and to save time, we'll ignore this and click **Next**
7. On the **Install hardware updates** page, in a nested environment it's likely you'll have no updates, so click **Next**
8. On the **Restart servers** page, if required, click **Restart servers**

![Restart nodes in the Create Cluster wizard](/media/wac_restart_ga.png "Restart nodes in the Create Cluster wizard")

### Networking ###
With the servers configured with the appropriate features, updated and rebooted, you're ready to configure your network.  You have a number of different choices here, so we'll try to explain why we're making each selection, so you can better apply it to your environment further down the road.

Firstly, Windows Admin Center will verify your networking setup - it'll tell you how many NICs are in each node, along with relevant hardware information, MAC address and status information.  Review for accuracy, and then click **Next**

![Verify network in the Create Cluster wizard](/media/wac_verify_network_ga.png "Verify network in the Create Cluster wizard")

The first key step with setting up the networking with Windows Admin Center, is to choose a management NIC that will be dedicated for management use.  You can choose either a single NIC, or two NICs for redundancy. This step specifically designates 1 or 2 adapters that will be used by the Windows Admin Center to orchestrate the cluster creation flow. It's mandatory to select at least one of the adapters for management, and in a physical deployment, the 1GbE NICs are usually good candidates for this.

As it stands, this is the way that the Windows Admin Center approaches the network configuration, however, if you were not using the Windows Admin Center, through PowerShell, there are a number of different ways to configure the network to meet your needs. We will work through the Windows Admin Center approach in this guide.

#### Network Setup Overview ####
Each of your Azure Stack HCI 20H2 nodes should have 4 NICs.  For this simple evaluation, you'll dedicate the NICs in the following way:

* 1 NIC will be dedicated to management. This NIC will reside on the 192.168.0.0/24 subnet. No virtual switch will be attached to this NIC.
* 1 NIC will be dedicated to VM traffic. A virtual switch will be attached to this NIC and the Azure Stack HCI 20H2 host will no longer use this NIC for it's own traffic.
* 2 NICs will be dedicated to storage traffic. They will reside on 2 separate subnets, 10.10.11.0/24 and 10.10.12.0/24. No virtual switches will be attached to these NICs.

Again, this is just one **example** network configuration for the simple purpose of evaluation.

1. Back in the Windows Admin Center, on the **Select the adapters to use for management** page, ensure you select the **Two physical network adapters for management** box

![Select management adapter in the Create Cluster wizard](/media/wac_management_nic_ga.png "Select management adapter in the Create Cluster wizard")

2. Then, for each node, **select the highlighted NIC** that will be dedicated for management.  The reason only one NIC is highlighted, is because this is the only NICs that has an IP address on the same network as the WAC instance. Once you've finished your selections, scroll to the bottom, then click **Apply and test**. This will take a few moments.

![Select management adapters in the Create Cluster wizard](/media/wac_singlemgmt_ga.png "Select management adapters in the Create Cluster wizard")

3. Windows Admin Center will then apply the configuration to your NICs. When complete and successful, click **Next**
4. On the **Virtual Switch** page, you have a number of options

![Select vSwitch in the Create Cluster wizard](/media/wac_vswitches_ga.png "Select vSwitch in the Create Cluster wizard")

* **Create one virtual switch for compute and storage together** - in this configuration, your Azure Stack HCI 20H2 nodes will create a vSwitch, comprised of multiple NICs, and the bandwidth available across these NICs will be shared by the Azure Stack HCI 20H2 nodes themselves, for storage traffic, and in addition, any VMs you deploy on top of the nodes, will also share this bandwidth.
* **Create one virtual switch for compute only** - in this configuration, you would leave some NICs dedicated to storage traffic, and have a set of NICs attached to a vSwitch, to which your VMs traffic would be dedicated.
* **Create two virtual switches** - in this configuration, you can create separate vSwitches, each attached to different sets of underlying NICs.  This may be useful if you wish to dedicate a set of underlying NICs to VM traffic, and another set to storage traffic, but wish to have vNICs used for storage communication instead of the underlying NICs.
* You also have a check-box for **Skip virtual switch creation** - if you want to define things later, that's fine too

1. Select the **Create one virtual switch for compute only**, and select the NIC on each node with the **10.10.13.x IP address**, then click **Next**

![Create single vSwitch for Compute in the Create Cluster wizard](/media/wac_compute_vswitch_ga.png "Create single vSwitch for Compute in the Create Cluster wizard")

6. On the **RDMA** page, you're now able to configure the appropriate RDMA settings for your host networks.  If you do choose to tick the box, in a nested environment, you'll be presented with an error, so click **Next**

![Error message when configuring RDMA in a nested environment](/media/wac_enable_rdma.png "Error message when configuring RDMA in a nested environment")

7. On the **Define networks** page, this is where you can define the specific networks, separate subnets, and optionally apply VLANs.  In this **nested environment**, we now have 3 NICs remaining.  Configure your remaining NICs as follows, by clicking on a field in the table and entering the appropriate information.

**NOTE** - we have a simple flat network in this configuration. One of the NICs have been claimed by the Management NIC, The remaining NICs will be show in the table in WAC, so ensure they align with the information below. WAC won't allow you to proceed unless everything aligns correctly.

| Node | Name | IP Address | Subnet Mask
| :-- | :-- | :-- | :-- |
| AZSHCINODE01 | Storage 1 | 10.10.11.1 | 24
| AZSHCINODE01 | Storage 2 | 10.10.12.1 | 24
| AZSHCINODE01 | VM | 10.10.13.1 | 24
| AZSHCINODE02 | Storage 1 | 10.10.11.2 | 24
| AZSHCINODE02 | Storage 2 | 10.10.12.2 | 24
| AZSHCINODE02 | VM | 10.10.13.2 | 24

When you click **Apply and test**, Windows Admin Center validates network connectivity between the adapters in the same VLAN and subnet, which may take a few moments.  Once complete, your configuration should look similar to this:

![Define networks in the Create Cluster wizard](/media/wac_define_network_ga.png "Define networks in the Create Cluster wizard")

**NOTE**, You *may* be prompted with a **Credential Security Service Provider (CredSSP)** box - read the information, then click **Yes**

![Validate cluster in the Create Cluster wizard](/media/wac_credssp_ga.png "Validate cluster in the Create Cluster wizard")

8. Once the networks have been verified, you can optionally review the networking test report, and once complete, click **Next**

9. Once changes have been successfully applied, click **Next: Clustering**

### Clustering ###
With the network configured for the workshop environment, it's time to construct the local cluster.

1. At the start of the **Cluster** wizard, on the **Validate the cluster** page, click **Validate**.

2. Cluster validation will then start, and will take a few moments to complete - once completed, you should see a successful message.

**NOTE** - Cluster validation is intended to catch hardware or configuration problems before a cluster goes into production. Cluster validation helps to ensure that the Azure Stack HCI 20H2 solution that you're about to deploy is truly dependable. You can also use cluster validation on configured failover clusters as a diagnostic tool. If you're interested in learning more about Cluster Validation, [check out the official docs](https://docs.microsoft.com/en-us/azure-stack/hci/deploy/validate "Cluster validation official documentation").

![Validation complete in the Create Cluster wizard](/media/wac_validated_ga.png "Validation complete in the Create Cluster wizard")

1. Optionally, if you want to review the validation report, click on **Download report** and open the file in your browser.
2. Back in the **Validate the cluster** screen, click **Next**
3. On the **Create the cluster** page, enter your **cluster name** as **AZSHCICLUS**
4. Under **IP address**, click **Assign dynamically using DHCP**
5. Expand **Advanced** and review the settings, then click **Create cluster**

![Finalize cluster creation in the Create Cluster wizard](/media/wac_create_clus_dhcp_ga.png "Finalize cluster creation in the Create Cluster wizard")

6. With all settings confirmed, click **Create cluster**. This will take a few moments.  Once complete, click **Next: Storage**

![Cluster creation successful in the Create Cluster wizard](/media/wac_cluster_success_ga.png "Cluster creation successful in the Create Cluster wizard")

### Storage ###
With the cluster successfully created, you're now good to proceed on to configuring your storage.  Whilst less important in a fresh nested environment, it's always good to start from a clean slate, so first, you'll clean the drives before configuring storage.

1. On the storage landing page within the Create Cluster wizard, click **Erase Drives**, and when prompted, with **You're about to erase all existing data**, click **Erase drives**.  Once complete, you should have a successful confirmation message, then click **Next**

![Cleaning drives in the Create Cluster wizard](/media/wac_clean_drives_ga.png "Cleaning drives in the Create Cluster wizard")

2. On the **Check drives** page, validate that all your drives have been detected, and show correctly.  As these are virtual disks in a nested environment, they won't display as SSD or HDD etc. You should have **4 data drives** per node.  Once verified, click **Next**

![Verified drives in the Create Cluster wizard](/media/wac_check_drives_ga.png "Verified drives in the Create Cluster wizard")

3. Storage Spaces Direct validation tests will then automatically run, which will take a few moments.

![Verifying Storage Spaces Direct in the Create Cluster wizard](/media/wac_validate_storage_ga.png "Verifying Storage Spaces Direct in the Create Cluster wizard")

4. Once completed, you should see a successful confirmation.  You can scroll through the brief list of tests, or alternatively, click to **Download report** to view more detailed information, then click **Next**

![Storage verified in the Create Cluster wizard](/media/wac_storage_validated_ga.png "Storage verified in the Create Cluster wizard")

5. The final step with storage, is to **Enable Storage Spaces Direct**, so click **Enable**.  This will take a few moments.

![Storage Spaces Direct enabled in the Create Cluster wizard](/media/wac_s2d_enabled_ga.png "Storage Spaces Direct enabled in the Create Cluster wizard")

6. With Storage Spaces Direct enabled, click **Finish**
7. On the **confirmation page**, click on **Go to connections list**

Configuring the cluster witness
-----------
By deploying an Azure Stack HCI 20H2 cluster, you're providing high availability for workloads. These resources are considered highly available if the nodes that host resources are up; however, the cluster generally requires more than half the nodes to be running, which is known as having quorum.

Quorum is designed to prevent split-brain scenarios which can happen when there is a partition in the network and subsets of nodes cannot communicate with each other. This can cause both subsets of nodes to try to own the workload and write to the same disk which can lead to numerous problems. However, this is prevented with Failover Clustering's concept of quorum which forces only one of these groups of nodes to continue running, so only one of these groups will stay online.

Typically, the recommendation is to utilize a **Cloud Witness**, where an Azure Storage Account is used to help provide quorum, but in the interest of time, we;re going to use a **File Share Witness**.  If you want to learn more about quorum, [check out the official documentation.](https://docs.microsoft.com/en-us/azure-stack/hci/concepts/quorum "Official documentation about Cluster quorum")

As part of this workshop, we're going to set up cluster quorum, using **Windows Admin Center**.

1. Firstly, you're going to create a **shared folder** on **HybridHost001** - open **File Explorer** and navigate to **V:\Witness**
2. **Right-click** on the Witness folder, select **Give access to**, then select **Specific people**
3. In the **Network access** window, use the drop-down to select **Everyone** and set their permissions to **Read/Write** - this setting is for speed and simplicity. In a production environment, your folder would be shared specifically with the Cluster Object from Active Directory.

![Granting folder permissions for the file share witness](/media/grant_folder_permissions.png "Granting folder permissions for the file share witness")

4. If you're not already, ensure you're logged into your **Windows Admin Center** instance, and click on your **azshciclus** cluster that you created earlier

![Connect to your cluster with Windows Admin Center](/media/wac_azshciclus_ga.png "Connect to your cluster with Windows Admin Center")

2. You may be prompted for credentials, so log in with your **hybrid\azureuser** credentials and tick the **Use these credentials for all connections** box. You should then be connected to your **azshciclus cluster**
3. After a few moments of verification, the **cluster dashboard** will open. 
4. On the **cluster dashboard**, at the very bottom-left of the window, click on **Settings**
5. In the **Settings** window, click on **Witness** and under **Witness type**, use the drop-down to select **File Share Witness**

![Set up file share witness in Windows Admin Center](/media/wac_cloud_witness_new_ga.png "Set up file share witness in Windows Admin Center")


17. With all the information gathered, return to the **Windows Admin Center** and complete the form with your values, then click **Save**

![Providing storage account info in Windows Admin Center](/media/wac_azure_key_ga.png "Providing storage account info in Windows Admin Center")

18. Within a few moments, your witness settings should be successfully applied and you have now completed configuring the quorum settings for the **azshciclus** cluster.

Connect and Register Azure Stack HCI 20H2 to Azure
-----------
Azure Stack HCI 20H2 is delivered as an Azure service and needs to register within 30 days of installation per the Azure Online Services Terms.  With our cluster configured, we'll now register your Azure Stack HCI 20H2 cluster with **Azure Arc** for monitoring, support, billing, and hybrid services. Upon registration, an Azure Resource Manager resource is created to represent each on-premises Azure Stack HCI 20H2 cluster, effectively extending the Azure management plane to Azure Stack HCI 20H2. Information is periodically synced between the Azure resource and the on-premises cluster.  One great aspect of Azure Stack HCI 20H2, is that the Azure Arc registration is a native capability of Azure Stack HCI 20H2, so there is no agent required.

**NOTE** - After registering your Azure Stack HCI 20H2 cluster, the **first 30 days usage will be free**.

### Prerequisites for registration ###
Firstly, **you need an Azure Stack HCI 20H2 cluster**, which we've just created, so you're good there.

Your nodes need to have **internet connectivity** in order to register and communicate with Azure.  If you've been running nested in Azure, you should have this already set up correctly, but if you're running nested on a local physical machine, make any necessary adjustments to your InternalNAT switch to allow internet connections through to your nested Azure Stack HCI 20H2 nodes.

You'll need an **Azure subscription**, along with appropriate **Azure Active Directory permissions** to complete the registration process. If you don't already have them, you'll need to ask your Azure AD administrator to grant permissions or delegate them to you.  You can learn more about this below.

#### What happens when you register Azure Stack HCI 20H2? ####
When you register your Azure Stack HCI 20H2 cluster, the process creates an Azure Resource Manager (ARM) resource to represent the on-prem cluster. This resource is provisioned by an Azure resource provider (RP) and placed inside a resource group, within your chosen Azure subscription.  If these Azure concepts are new to you, you can check out an [overview of them, and more, here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview "Azure Resource Manager overview").

![ARM architecture for Azure Stack HCI 20H2](/media/azure_arm.png "ARM architecture for Azure Stack HCI 20H2")

In addition to creating an Azure resource in your subscription, registering Azure Stack HCI 20H2 creates an app identity, conceptually similar to a user, in your Azure Active Directory tenant. The app identity inherits the cluster name. This identity acts on behalf on the Azure Stack HCI 20H2 cloud service, as appropriate, within your subscription.

#### Understanding required Azure Active Directory permissions ####
If the user who registers Azure Stack HCI 20H2 is an Azure Active Directory global administrator or has been delegated sufficient permissions, this all happens automatically, and no additional action is required. If not, approval may be needed from your Azure Active Directory global administrator (or someone with appropriate permissions) to complete registration. Your global administrator can either explicitly grant consent to the app, or they can delegate permissions so that you can grant consent to the app.

![Azure Active Directory Permissions](/media/aad_permissions.png "Azure Active Directory Permissions")

The user who runs Register-AzStackHCI needs Azure AD permissions to:

* Create/Get/Set/Remove Azure AD applications (New/Get/Set/Remove-AzureADApplication)
* Create/Get Azure AD service principal (New/Get-New-AzureADServicePrincipal)
* Manage AD application secrets (New/Get/Remove-AzureADApplicationKeyCredential)
* Grant consent to use specific application permissions (New/Get/Remove AzureADServiceAppRoleAssignments)

There are three ways in which this can be accomplished.

#### Option 1: Allow any user to register applications ####

In Azure Active Directory, navigate to User settings > **App registrations**. Under **Users can register applications**, select **Yes**.

This will allow any user to register applications. However, the user will still require the Azure AD admin to grant consent during cluster registration. Note that this is a tenant level setting, so it may not be suitable for large enterprise customers.

#### Option 2: Assign Cloud Application Administration role ####

Assign the built-in "Cloud Application Administration" Azure AD role to the user. This will allow the user to register clusters without the need for additional AD admin consent.

#### Option 3: Create a custom AD role and consent policy ####

The most restrictive option is to create a custom AD role with a custom consent policy that delegates tenant-wide admin consent for required permissions to the Azure Stack HCI Service. When assigned this custom role, users are able to both register and grant consent without the need for additional AD admin consent.

**NOTE** - This option requires an Azure AD Premium license and uses custom AD roles and custom consent policy features which are currently in public preview.

If you choose to perform Option 3, you'll need to follow these steps on **HybridHost001**, which we'll demonstrate mainly through PowerShell.

1. Firstly, configure the appropriate AzureAD modules, then **Connect to Azure AD**, and when prompted, **log in with your appropriate credentials**

```powershell
Remove-Module AzureAD -ErrorAction SilentlyContinue -Force
Install-Module AzureADPreview -AllowClobber -Force
Connect-AzureAD
```

2. Create a **custom consent policy**:

```powershell
New-AzureADMSPermissionGrantPolicy -Id "AzSHCI-registration-consent-policy" `
    -DisplayName "Azure Stack HCI registration admin app consent policy" `
    -Description "Azure Stack HCI registration admin app consent policy"
```

3. Add a condition that includes required app permissions for Azure Stack HCI service, which carries the app ID 1322e676-dee7-41ee-a874-ac923822781c. Note that the following permissions are for the GA release of Azure Stack HCI, and will not work with Public Preview unless you have applied the [November 23, 2020 Preview Update (KB4586852)](https://docs.microsoft.com/en-us/azure-stack/hci/release-notes "November 23, 2020 Preview Update (KB4586852)") to every server in your cluster and have downloaded the Az.StackHCI module version 0.4.1 or later.

```powershell
New-AzureADMSPermissionGrantConditionSet -PolicyId "AzSHCI-registration-consent-policy" `
    -ConditionSetType "includes" -PermissionType "application" -ResourceApplication "1322e676-dee7-41ee-a874-ac923822781c" `
    -Permissions "bbe8afc9-f3ba-4955-bb5f-1cfb6960b242", "8fa5445e-80fb-4c71-a3b1-9a16a81a1966", `
    "493bd689-9082-40db-a506-11f40b68128f", "2344a320-6a09-4530-bed7-c90485b5e5e2"
```

4. Grant permissions to allow registering Azure Stack HCI, noting the custom consent policy created in Step 2:

```powershell
$displayName = "Azure Stack HCI Registration Administrator "
$description = "Custom AD role to allow registering Azure Stack HCI "
$templateId = (New-Guid).Guid
$allowedResourceAction =
@(
    "microsoft.directory/applications/createAsOwner",
    "microsoft.directory/applications/delete",
    "microsoft.directory/applications/standard/read",
    "microsoft.directory/applications/credentials/update",
    "microsoft.directory/applications/permissions/update",
    "microsoft.directory/servicePrincipals/appRoleAssignedTo/update",
    "microsoft.directory/servicePrincipals/appRoleAssignedTo/read",
    "microsoft.directory/servicePrincipals/appRoleAssignments/read",
    "microsoft.directory/servicePrincipals/createAsOwner",
    "microsoft.directory/servicePrincipals/credentials/update",
    "microsoft.directory/servicePrincipals/permissions/update",
    "microsoft.directory/servicePrincipals/standard/read",
    "microsoft.directory/servicePrincipals/managePermissionGrantsForAll.AzSHCI-registration-consent-policy"
)
$rolePermissions = @{'allowedResourceActions' = $allowedResourceAction }
```

5. Create the new custom AD role:

```powershell
$customADRole = New-AzureADMSRoleDefinition -RolePermissions $rolePermissions `
    -DisplayName $displayName -Description $description -TemplateId $templateId -IsEnabled $true
```

6. Assign the new custom AD role to the user who will register the Azure Stack HCI cluster with Azure by following [these instructions](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-users-assign-role-azure-portal "Guidance on creating a custom Azure AD role").

### Complete Registration ###
To complete registration, you have 2 options - you can use **Windows Admin Center**, or you can use **PowerShell**.

#### Option 1 - Register using Windows Admin Center ####

1. On **HybridHost001**, logged in as **azshci\labadmin**, open the Windows Admin Center, and on the **All connections** page, select your azshciclus
2. When the cluster dashboard has loaded, in the top-right corner, you'll see the **status of the Azure registration/connection**

![Azure registration status in Windows Admin Center](/media/wac_azure_reg_dashboard.png "Azure registration status in Windows Admin Center")

3. Click on **Install PowerShell modules** to trigger Windows Admin Center to download and install the appropriate PowerShell modules to the Azure Stack HCI 20H2 node. This may take a few moments.

![Azure registration status in Windows Admin Center](/media/wac_azure_reg_dashboard_2.png "Azure registration status in Windows Admin Center")

4. Once installed, you can begin the registration process by clicking **Register this cluster**
5. If you haven't already, you'll be prompted to register Windows Admin Center with an Azure tenant.  Follow the instructions to **Copy the code** and then click on the link to configure device login.
6. When prompted for credentials, **enter your Azure credentials** for a tenant you'd like to register the Windows Admin Center
7. Back in Windows Admin Center, you'll notice your tenant information has been added.  You can now click **Connect** to connect Windows Admin Center to Azure

![Connecting Windows Admin Center to Azure](/media/wac_azure_connect.png "Connecting Windows Admin Center to Azure")

8. Click on **Sign in** and when prompted for credentials, **enter your Azure credentials** and you should see a popup that asks for you to accept the permissions, so click **Accept**

![Permissions for Windows Admin Center](/media/wac_azure_permissions.png "Permissions for Windows Admin Center")

9. Back in Windows Admin Center, you may need to refresh the page if your 'Register this cluster' link is not active. Once active, click **Register this cluster** and you should be presented with a window requesting more information.
10. Choose your **Azure subscription** that you'd like to use to register, along with an **Azure resource group** and **region**, then click **Register**.  This will take a few moments.

![Final step for registering Azure Stack HCI with Windows Admin Center](/media/wac_azure_register.png "Final step for registering Azure Stack HCI with Windows Admin Center")

11. Once completed, you should see updated status on the Windows Admin Center dashboard, showing that the cluster has been correctly registered.

![Azure registration status in Windows Admin Center](/media/wac_azure_reg_dashboard_3.png "Azure registration status in Windows Admin Center")

You can now proceed on to [Viewing registration details in the Azure portal](#View-registration-details-in-the-Azure-portal)

#### Option 2 - Register using PowerShell ####
We're going to perform the registration from the **HybridHost001** machine, which we've been using with the Windows Admin Center.

1. On **HybridHost001**, open **PowerShell as administrator** and run the following code to install the PowerShell Module for Azure Stack HCI 20H2 on that machine.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Install-Module Az.StackHCI
```

**NOTE** - You may recieve a message that **PowerShellGet requires NuGet Provider...** - read the full message, and then click **Yes** to allow the appropriate dependencies to be installed. You may receive a second prompt to **install the modules from the PSGallery** - click **Yes to All** to proceed.

In addition, in future releases, installing the Azure PowerShell **Az** modules will include **StackHCI**, however today, you have to install this module specifically, using the command **Install-Module Az.StackHCI**

2. With the Az.StackHCI modules installed, it's now time to register your Azure Stack HCI 20H2 cluster to Azure, however first, it's worth exploring how to check existing registration status.  The following code assumes you are still in the remote PowerShell session open from the previous commands.

```powershell
Invoke-Command -ComputerName AZSHCINODE01 -ScriptBlock {
    Get-AzureStackHCI
}
```

![Check the registration status of the Azure Stack HCI 20H2 cluster](/media/reg_check.png "Check the registration status of the Azure Stack HCI 20H2 cluster")

As you can see from the result, the cluster is yet to be registered, and the cluster status identifies as **Clustered**. Azure Stack HCI 20H2 needs to register within 30 days of installation per the Azure Online Services Terms. If not clustered after 30 days, the **ClusterStatus** will show **OutOfPolicy**, and if not registered after 30 days, the **RegistrationStatus** will show **OutOfPolicy**.

3. To register the cluster, you'll first need to get your **Azure subscription ID**.  An easy way to do this is to quickly **log into https://portal.azure.com**, and in the **search box** at the top of the screen, search for **subscriptions** and then click on **Subscriptions**

![Azure Subscriptions](/media/azure_subscriptions_ga.png "Azure Subscriptions")

4. Your **subscription** should be shown in the main window.  If you have more than one subscription listed here, click the correct one, and in the new blade, copy the **Subscription ID**.

**NOTE** - If you don't see your desired subscription, in the top right-corner of the Azure portal, click on your user account, and click **Switch directory**, then select an alternative directory.  Once in the chosen directory, repeat the search for your **Subscription ID** and copy it down.

5. With your **Subscription ID** in hand, you can **register using the following Powershell commands**, from your open PowerShell window.

```powershell
$azshciNodeCreds = Get-Credential -UserName "hybric\azureuser" -Message "Enter the Lab Admin password"
Register-AzStackHCI `
    -SubscriptionId "your-subscription-ID-here" `
    -ResourceName "azshciclus" `
    -ResourceGroupName "AZSHCICLUS_RG" `
    -Region "EastUS" `
    -EnvironmentName "AzureCloud" `
    -ComputerName "AZSHCINODE01.hybrid.local" `
    –Credential $azshciNodeCreds
```

Of these commands, many are optional:

* **-ResourceName** - If not declared, the Azure Stack HCI 20H2 cluster name is used
* **-ResourceGroupName** - If not declared, the Azure Stack HCI 20H2 cluster plus the suffix "-rg" is used
* **-Region** - If not declared, "EastUS" will be used.  Additional regions are supported, with the longer term goal to integrate with Azure Arc in all Azure regions.
* **-EnvironmentName** - If not declared, "AzureCloud" will be used, but allowed values will include additional environments in the future
* **-ComputerName** - This is used when running the commands remotely against a cluster.  Just make sure you're using a domain account that has admin privilege on the nodes and cluster
* **-Credential** - This is also used for running the commands remotely against a cluster.

**Register-AzureStackHCI** runs syncronously, with progress reporting, and typically takes 1-2 minutes.  The first time you run it, it may take slightly longer, because it needs to install some dependencies, including additional Azure PowerShell modules.

6. Once dependencies have been installed, you'll receive a popup on **HybridHost001** to authenticate to Azure. Provide your **Azure credentials**.

![Login to Azure](/media/azure_login_reg.png "Login to Azure")

7. Once successfully authenticated, the registration process will begin, and will take a few moments. Once complete, you should see a message indicating success, as per below:

![Register Azure Stack HCI 20H2 with PowerShell](/media/register_azshci_ga.png "Register Azure Stack HCI 20H2 with PowerShell")

**NOTE** - if upon registering, you receive an error similar to that below, please **try a different region**.  You can still proceed to [Step 5](#next-steps) and continue with your evaluation, and it won't affect any functionality.  Just make sure you come back and register later!

```
Register-AzStackHCI : Azure Stack HCI 20H2 is not yet available in region <regionName>
```

8. Once the cluster is registered, run the following command on **HybridHost001** to check the updated status:

```powershell
Invoke-Command -ComputerName AZSHCINODE01 -ScriptBlock {
    Get-AzureStackHCI
}
```
![Check updated registration status with PowerShell](/media/registration_status.png "Check updated registration status with PowerShell")

You can see the **ConnectionStatus** and **LastConnected** time, which is usually within the last day unless the cluster is temporarily disconnected from the Internet. An Azure Stack HCI 20H2 cluster can operate fully offline for up to 30 consecutive days.

### View registration details in the Azure portal ###
With registration complete, either through Windows Admin Center, or through PowerShell, you should take some time to explore the artifacts that are created in Azure, once registration successfully completes.

1. On **HybridHost001**, open the Edge browser and **log into https://portal.azure.com** to check the resources created there. In the **search box** at the top of the screen, search for **Resource groups** and then click on **Resource groups**
2. You should see a new **Resource group** listed, with the name you specified earlier, which in our case, is **AZSHCICLUS_RG**

![Registration resource group in Azure](/media/registration_rg_ga.png "Registration resource group in Azure")

12. Click on the **AZSHCICLUS_RG** resource group, and in the central pane, you'll see that a record with the name **azshciclus** has been created inside the resource group
13. Click on the **azihciclus** record, and you'll be taken to the new Azure Stack HCI Resource Provider, which shows information about all of your clusters, including details on the currently selected cluster

![Overview of the recently registered cluster in the Azure portal](/media/azure_portal_hcicluster.png "Overview of the recently registered cluster in the Azure portal")

**NOTE** - If when you ran **Register-AzureStackHCI**, you don't have appropriate permissions in Azure Active Directory, to grant admin consent, you will need to work with your Azure Active Directory administrator to complete registration later. You can exit and leave the registration in status "**pending admin consent**," i.e. partially completed. Once consent has been granted, **simply re-run Register-AzureStackHCI** to complete registration.

### Congratulations! ###
You've now successfully deployed, configured and registered your Azure Stack HCI 20H2 cluster!

Next Steps
-----------
In this step, you've successfully created a nested Azure Stack HCI 20H2 cluster using Windows Admin Center.  With this complete, you can now [Deploy your AKS-HCI infrastructure](/steps/3_DeployAKSHCI.md "Deploy your AKS-HCI infrastructure")

Product improvements
-----------
If, while you work through this guide, you have an idea to make the product better, whether it's something in Azure Stack HCI, AKS on Azure Stack HCI, Windows Admin Center, or the Azure Arc integration and experience, let us know! We want to hear from you!

For **Azure Stack HCI**, [Head on over to the Azure Stack HCI 20H2 Q&A forum](https://docs.microsoft.com/en-us/answers/topics/azure-stack-hci.html "Azure Stack HCI 20H2 Q&A"), where you can share your thoughts and ideas about making the technologies better and raise an issue if you're having trouble with the technology.

For **AKS on Azure Stack HCI**, [Head on over to our AKS on Azure Stack HCI 20H2 GitHub page](https://github.com/Azure/aks-hci/issues "AKS on Azure Stack HCI GitHub"), where you can share your thoughts and ideas about making the technologies better. If however, you have an issue that you'd like some help with, read on... 

Raising issues
-----------
If you notice something is wrong with this guide, such as a step isn't working, or something just doesn't make sense - help us to make this guide better!  Raise an issue in GitHub, and we'll be sure to fix this as quickly as possible!

If you're having an issue with Azure Stack HCI 20H2 **outside** of this guide, [head on over to the Azure Stack HCI 20H2 Q&A forum](https://docs.microsoft.com/en-us/answers/topics/azure-stack-hci.html "Azure Stack HCI 20H2 Q&A"), where Microsoft experts and valuable members of the community will do their best to help you.

If you're having a problem with AKS on Azure Stack HCI **outside** of this guide, make sure you post to [our GitHub Issues page](https://github.com/Azure/aks-hci/issues "GitHub Issues"), where Microsoft experts and valuable members of the community will do their best to help you.