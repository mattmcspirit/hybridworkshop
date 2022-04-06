Deploy your AKS-HCI infrastructure
==============
Overview
-----------
It's now time to deploy AKS on Azure Stack HCI. You'll first deploy the AKS on Azure Stack HCI management cluster, and then deploy a target cluster, onto which you can test deployment of a workload.

Contents
-----------
- [Overview](#overview)
- [Contents](#contents)
- [Architecture](#architecture)
- [Allow popups in Edge browser](#allow-popups-in-edge-browser)
- [Configure Windows Admin Center](#configure-windows-admin-center)
- [Validate Azure integration](#validate-azure-integration)
- [Deploying the AKS on Azure Stack HCI management cluster](#deploying-the-aks-on-azure-stack-hci-management-cluster)
- [Create a Kubernetes cluster (Target cluster)](#create-a-kubernetes-cluster-target-cluster)
- [Scale your Kubernetes cluster (Target cluster)](#scale-your-kubernetes-cluster-target-cluster)
- [Next Steps](#next-steps)
- [Product improvements](#product-improvements)
- [Raising issues](#raising-issues)

Architecture
-----------

From an architecture perspective, as shown earlier, this graphic showcases the different layers and interconnections between the different components:

![Architecture diagram for AKS on Azure Stack HCI in Azure](/media/nested_virt_akshci_ga.png "Architecture diagram for AKS on Azure Stack HCI in Azure")

In this section, you'll use Windows Admin Center to deploy the AKS on Azure Stack HCI, including all the key components. First, the management cluster (kubernetes virtual appliance) provides the the core orchestration mechanism and interface for deploying and managing one or more target clusters. These target, or workload clusters contain worker nodes and are where application workloads run. If you're interested in learning more about the building blocks of the Kubernetes infrastructure, you can [read more here](https://docs.microsoft.com/en-us/azure-stack/aks-hci/kubernetes-concepts "Kubernetes core concepts for Azure Kubernetes Service on Azure Stack HCI").

As mentioned earlier, Azure Stack HCI and AKS-HCI will de deployed as 2 separate environments within the same Azure VM. In a production environment, you would run AKS-HCI **on top of** Azure Stack HCI, but in this nested environment, the performance of the multiple levels of nesting can have a negative impact, so in this case, they will be deployed side by side for evaluation.

Allow popups in Edge browser
-----------
To give the optimal experience with Windows Admin Center, you should enable **Microsoft Edge** to allow popups for Windows Admin Center. If you performed this step earlier, you can skip this step.

1. Still inside your **HybridHost001 VM**, double-click the **Microsoft Edge icon** on your desktop
2. Navigate to **edge://settings/content/popups**
3. In the **Allow** box, click on **Add**
4. In the **Add a site** box, enter **https://HybridHost001** (assuming you didn't change the host name at deployment time)

![Allow popups in Edge](/media/allow_popup_edge.png "Allow popups in Edge")

5. Close the **settings tab**.

Configure Windows Admin Center
-----------
Your Azure VM deployment automatically installed the latest version of Windows Admin Center, however there are some additional configuration steps that must be performed before you can use it to deploy AKS on Azure Stack HCI.

1. **Double-click the Windows Admin Center** shortcut on the desktop.
2. Once Windows Admin Center is open, you may receive notifications in the top-right corner, indicating that some extensions are updating automatically. **Let these finish updating before proceeding**. Windows Admin Center may refresh automatically during this process.
3. Once complete, navigate to **Settings**, then **Extensions**
4. Click on **Installed extensions** and you should see **Azure Kubernetes Service** listed as installed

![Installed extensions in Windows Admin Center](/media/installed_extensions.png "Installed extensions in Windows Admin Center")

____________

**NOTE** - Ensure that your Azure Kubernetes Service extension is the **latest available version**. If the **Status** is **Installed**, you have the latest version. If the **Status** shows **Update available (1.#.#)**, ensure you apply this update and refresh before proceeding.

_____________

In order to deploy AKS-HCI with Windows Admin Center, you need to connect your Windows Admin Center instance to Azure. If you performed this step earlier when registering Azure Stack HCI, you can skip ahead.

5. Still in **Settings**, under **Gateway** click on **Azure**.
6. Click **Register**, and in the **Get started with Azure in Windows Admin Center** blade, follow the instructions to **Copy the code** and then click on the link to configure device login.
7.   When prompted for credentials, **enter your Azure credentials** for a tenant you'd like to use to register the Windows Admin Center
8.   Back in Windows Admin Center, you'll notice your tenant information has been added.  You can now click **Connect** to connect Windows Admin Center to Azure

![Connecting Windows Admin Center to Azure](/media/wac_azure_connect.png "Connecting Windows Admin Center to Azure")

9.  Click on **Sign in** and when prompted for credentials, **enter your Azure credentials** and you should see a popup that asks for you to accept the permissions. Make sure you select **Consent on behalf of your organization** then click **Accept**

![Permissions for Windows Admin Center](/media/wac_azure_permissions.png "Permissions for Windows Admin Center")

*******************************************************************************************************

**NOTE** - if you receive an error when signing in, still in **Settings**, under **User**, click on **Account** and click **Sign-in**. You should then be prompted for Azure credentials and permissions, to which you can then click **Accept**. Sometimes it just takes a few moments from Windows Admin Center creating the Azure AD application and being able to sign in. Retry the sign-in until you've successfully signed in.

*******************************************************************************************************

Validate Azure integration
-----------
In order to successfully deploy AKS on Azure Stack HCI with Windows Admin Center, additional permissions were applied on the Windows Admin Center Azure AD application that was created when you connected Windows Admin Center to Azure, earlier. In this step, we'll quickly validate those permissions.

1. Still in Windows Admin Center, click on the **Settings** gear in the top-right corner
2. Under **Gateway**, click **Azure**. You should see your previously registered Azure AD app:

![Your Azure AD app in Windows Admin Center](/media/wac_azureadapp.png "Your Azure AD app in Windows Admin Center")

3. Click on **View in Azure** to be taken to the Azure AD app portal, where you should see information about this app, including permissions required. If you're prompted to log in, provide appropriate credentials.
4. Once logged in, under **Configured permissions**, you should see a few permissions listed with the status **Granted for...** and the name of your tenant. The **Microsoft Graph (5)** API permissions will show as **not granted** but this will be updated upon deployment

![Confirm Azure AD app permissions in Windows Admin Center](/media/wac_azuread_grant.png "Confirm Azure AD app permissions in Windows Admin Center")

*******************************************************************************************************

**NOTE** - If you don't see Microsoft Graph listed in the API permissions, you can either [re-register Windows Admin Center using steps here](#configure-windows-admin-center "re-register Windows Admin Center using steps here") for the permissions to appear correctly, or manually add the **Microsoft Graph Appliation.ReadWrite.All** permission. To manually add the permission:

- Click **+ Add a permission**
- Select **Microsoft Graph**, then **Delegated permissions**
- Search for **Application.ReadWrite.All**, then if required, expand the **Application** dropdown
- Select the **checkbox** and click **Add permissions**

*******************************************************************************************************

5. Switch back to the **Windows Admin Center tab** and click on **Windows Admin Center** in the top-left corner to return to the home page

You'll notice that your HybridHost001 is already under management, so at this stage, you're ready to proceed to deploy the AKS on Azure Stack HCI management cluster onto your Windows Server 2019 Hyper-V host.

![HybridHost001 under management in Windows Admin Center](/media/akshcihost_in_wac.png "HybridHost001 under management in Windows Admin Center")

Deploying the AKS on Azure Stack HCI management cluster
-----------
The next section will walk through configuring the AKS on Azure Stack HCI management cluster, on your single node Windows Server 2019 host.

1. From the Windows Admin Center homepage, click on your **HybridHost001.hybrid.local** cluster.
2. You'll be presented with a rich array of information about your HybridHost001 cluster, of which you can feel free to explore the different options and metrics. When you're ready, on the left-hand side, scroll down and under **Extensions**, click **Azure Kubernetes Service**

![Ready to deploy AKS-HCI with Windows Admin Center](/media/aks_extension.png "Ready to deploy AKS-HCI with Windows Admin Center")

You'll notice the terminology used refers to the **Azure Kubernetes Service Runtime on Windows Server​​** - the naming differs depending on if you're running the installation of AKS on a Windows Server 2019 Hyper-V platform, or the newer Azure Stack HCI 21H2 platform. The overall deployment experience is the same regardless of underlying platform.

3. Click on **Set up** to start the deployment process
4. Firstly, review the prerequisites - your Azure VM environment will meet all the prerequisites, so you should be fine to click **Next: System checks**
5. On the **System checks** page, enter the password for your **azureuser** account and when successfully validated, click on the **Install** button to **install the required PowerShell modules**
6. During the system checks stage, Windows Admin Center will begin to validate it's own configuration, and the configuration of your target nodes, which in this case, is the Windows Server 2019 Hyper-V host (HybridHost001, running in your Azure VM)

![System checks performed by Windows Admin Center](/media/wac_system_checks_single.png "System checks performed by Windows Admin Center")

You'll notice that Windows Admin Center will validate memory, storage, networking, roles and features and more. If you've followed the guide correctly, you'll find you'll pass all the checks and can proceed.

7. Once validated, click **Next: Credential delegation**
8. On the **Credential delegation** page, read the information about **CredSSP**, then click **Enable**. Once enabled, click **Next: Host configuration**

![Enable CredSSP in Windows Admin Center](/media/aks_hostconfig_credssp.png "Enable CredSSP in Windows Admin Center")

**NOTE** - if you receive a WinRM error, open an **Administrative PowerShell console** and run the following command and then retry:

```powershell
Restart-Service WinRm -Force
```

9.  On the **Host configuration** page, under **Host details**, select your **V:**, and leave the other settings as default

![Host configuration in Windows Admin Center](/media/aks_hostconfig_hostdetails_single.png "Host configuration in Windows Admin Center")

10. Under **VM Networking**, ensure that **InternalNAT** is selected for the **Internet-connected virtual switch**
11. For **Enable virtual LAN identification**, leave this selected as **No**
12. For **Cloudagent IP** this is optional, so we will leave this blank
13. For **IP address allocation method** choose **DHCP**

![Host configuration in Windows Admin Center](/media/aks_hostconfig_vmnet_int.png "Host configuration in Windows Admin Center")

14.  Under **Load balancer settings**, enter the range from **192.168.0.150** to **192.168.0.250** and then click **Next:Azure registration**

![Host configuration in Windows Admin Center](/media/aks_hostconfig_lb.png "Host configuration in Windows Admin Center")

16. On the **Azure registration page**, your Azure account should be automatically populated. Use the drop-down to select your preferred subscription. If you are prompted, log into Azure with your Azure credentials. Once successfully authenticated, you should see your **Account**, then **choose your subscription**

![AKS Azure Registration in Windows Admin Center](/media/aks_azure_reg.png "AKS Azure Registration in Windows Admin Center")

*******************************************************************************************************

**NOTE** - No charges will be incurred for using AKS on Azure Stack HCI for free trial period of 60 days.

*******************************************************************************************************

15. Once you've chosen your subscription, choose an **existing Resource Group** or **create a new one** - Your resource group should be in the **East US, Southeast Asia, or West Europe region**
16. Click on **Next:Review**
17. Review your choices and settings, then click **Apply**.
18. After a few moments, you may be **prompted to grant consent** to the Windows Admin Center Azure AD application. Ensure you select **Consent on behalf of your organization** then click **Accept**. The settings will be applied, and you should receive some notifications:

![Setting the AKS-HCI config in Windows Admin Center](/media/aks_host_mgmtconfirm.png "Setting the AKS-HCI config in Windows Admin Center")

19. Once confirmed, you can click **Next: New cluster** to start the deployment process of the management cluster.

![AKS on Azure Stack HCI management cluster deployment started in Windows Admin Center](/media/aks_deploy_started.png "AKS on Azure Stack HCI management cluster deployment started in Windows Admin Center")

*******************************************************************************************************

**NOTE 1** - Do not close the Windows Admin Center browser at this time. Leave it open and wait for successful completion.

**NOTE 2** - You may receive a WinRM error message stating "Downloading virtual machine images and binaries for the AKS host failed" - this can be ignored, so **do not close/refresh the browser**.

*******************************************************************************************************

20.  Upon completion you should receive a notification of success. In this case, you can see deployment of the AKS on Azure Stack HCI management cluster took just over 11 minutes.

![AKS-HCI management cluster deployment completed in Windows Admin Center](/media/aks_deploy_success.png "AKS-HCI management cluster deployment completed in Windows Admin Center")

21. Once reviewed, click **Finish**. You will then be presented with a management dashboard where you can create and manage your Kubernetes clusters.

### Updates and Cleanup ###
To learn more about **updating**, **redeploying** or **uninstalling** AKS on Azure Stack HCI with Windows Admin Center, you can [read the official documentation here.](https://docs.microsoft.com/en-us/azure-stack/aks-hci/setup "Official documentation on updating, redeploying and uninstalling AKS on Azure Stack HCI")

Create a Kubernetes cluster (Target cluster)
-----------
With the management cluster deployed successfully, you're ready to move on to deploying Kubernetes clusters that can host your workloads. We'll then briefly walk through how to scale your Kubernetes cluster and upgrade the Kubernetes version of your cluster.

There are two ways to create a Kubernetes cluster in Windows Admin Center.

#### Option 1 ####
1. From your Windows Admin Center landing page (https://HybridHost001), click on **+Add**.
2. In the **Add or create resources blade**, in the **Kubernetes clusters tile**, click **Create new**

![Create Kubernetes cluster in Windows Admin Center](/media/create_cluster_method1.png "Create Kubernetes cluster in Windows Admin Center")

#### Option 2 ####
1. From your Windows Admin Center landing page (https://HybridHost001), click on your **HybridHost001.hybrid.local \[Gateway\]** machine.
2. Then, on the left-hand side, scroll down and under **Extensions**, click **Azure Kubernetes Service**.
3. In the central pane, click on **Add cluster**

![Create Kubernetes cluster in Windows Admin Center](/media/create_cluster_method2.png "Create Kubernetes cluster in Windows Admin Center")

Whichever option you chose, you will now be at the start of the **Create kubernetes cluster** wizard.

1. Firstly, review the prerequisites - your Azure VM environment will meet all the prerequisites, so you should be fine to click **Next: Basics**
2. On the **Basics** page, firstly, choose whether you wish to **optionally** integrate with Azure Arc enabled Kubernetes. You can click the link on the page to learn more about Azure Arc. If you do wish to integrate, select the **Enabled** radio button, then use the drop downs to select the **subscription**,  **resource group** and **region**. Alternatively, you can create a new resource group, in a specific region, exclusively for the Azure Arc integration resource.

![Enable Arc integration with Windows Admin Center](/media/aks_basics_arc.png "Enable Arc integration with Windows Admin Center")

3. Still on the **Basics** page, under **Cluster details**, provide a **Kubernetes cluster name**, **Azure Kubernetes Service host**, which should be **HybridHost001.hybrid.local**, enter your host credentials, then select the **Kubernetes version** from the drop down.

![AKS cluster details in Windows Admin Center](/media/aks_basics_cluster_details_single.png "AKS cluster details in Windows Admin Center")

4. Under **Primary node pool**, accept the defaults, and then click **Next: Node pools**

![AKS primary node pool in Windows Admin Center](/media/aks_basics_primarynp.png "AKS primary node pool in Windows Admin Center")

5. On the **Node pools** page, click on **+Add node pool**
6. In the **Add a node pool** blade, enter the following, then click **Add**
   1. **Node pool name**: linuxnodepool
   2. **OS type**: Linux
   3. **Node size**: Standard_K8S3_v1 (6 GB Memory, 4 CPU)
   4. **Node count**: 1

![AKS node pools in Windows Admin Center](/media/aks_node_pools.png "AKS node pools in Windows Admin Center")

7. Once your **Node pools** have been defined, click **Next: Authentication**
8. For this evaluation, for **AD Authentication** click **Disabled** and then click **Next: Networking**
9. On the **Networking** page, review the **defaults**. For this deployment, you'll deploy this kubernetes cluster on the existing virtual network that was created when you installed AKS-HCI in the previous steps.

![AKS virtual networking in Windows Admin Center](/media/aks_virtual_networking.png "AKS virtual networking in Windows Admin Center")

10. Click on the **aks-default-network**, ensure **Calico** network configuration is selected, and then click **Next: Review + Create**
11. On the **Review + Create** page, review your chosen settings, then click **Create**

![Finalize creation of AKS cluster in Windows Admin Center](/media/aks_create.png "Finalize creation of AKS cluster in Windows Admin Center")

12. The creation process will begin and take a few minutes

![Start deployment of AKS cluster in Windows Admin Center](/media/aks_create_start.png "Start deployment of AKS cluster in Windows Admin Center")

13. Once completed, you should see a message for successful creation, then click **Finish**

![Completed deployment of AKS cluster in Windows Admin Center](/media/aks_create_complete.png "Completed deployment of AKS cluster in Windows Admin Center")

14. Back in the **Azure Kubernetes Service on Azure Stack HCI landing page**, you should now see your cluster listed. You may wish to download your **Kubernetes cluster kubeconfig** file in order to access this Kubernetes cluster via **kubectl** later, by selecting the cluster, and clicking **Download cluster kubeconfig**.

![AKS cluster in Windows Admin Center](/media/aks_dashboard.png "AKS cluster in Windows Admin Center")

15. On the dashboard, if you chose to integrate with Azure Arc, you should be able to click the **Azure instance** link to be taken to the Azure Arc view in the Azure portal.

![AKS cluster in Azure Arc](/media/aks_in_arc.png "AKS cluster in Azure Arc")

16. Once you have your Kubeconfig file, you can click **Finish**

Scale your Kubernetes cluster (Target cluster)
-----------
Next, you'll scale your Kubernetes cluster to add an additional Linux worker node. As it stands, this has to be performed with **PowerShell** but will be available in Windows Admin Center in the future.

1. Open **PowerShell as Administrator** and run the following command to import the new modules, and list their functions.

```powershell
Import-Module AksHci
Get-Command -Module AksHci
```

2. Next, to check on the status of the existing clusters, run the following

```powershell
Get-AksHciCluster
```

![Output of Get-AksHciCluster](/media/get_akshcicluster_wac1.png "Output of Get-AksHciCluster")

3. Next, you'll scale your Kubernetes cluster to have **2 Linux worker nodes** and **1 Windows worker node**. You'll do this by specifying a node pool to update.

**************************************

### Node Pools, Taints and Max Pod Counts ###

If you're not familiar with the concept of **node pools**, a node pool is a **group of nodes**, or virtual machines that run your applications, within a Kubernetes cluster that have the same configuration, giving you more granular control over your clusters. You can deploy multiple Windows node pools and multiple Linux node pools of different sizes, within the same Kubernetes cluster.

Another configuration option that can be applied to a node pool is the concept of **taints**. A taint can be specified for a particular node pool at cluster and node pool creation time, and essential allow you to prevent pods being placed on specific nodes based on characteristics that you specify. You can learn more about [taints here](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ "Information about taints").

This guide doesn't require you to specify a taint, but if you do wish to explore the commands for adding a taint to a node pool, make sure you read the [official docs](https://docs.microsoft.com/en-us/azure-stack/aks-hci/use-node-pools#specify-a-taint-for-a-node-pool "Official docs on taints").

In addition to taints, we have recently added suport for configuring the **maximum number of pods** that can run on a node with PowerShell, with the **-nodeMaxPodCount** parameter. You can specify this parameter when creating a cluster, or when creating a new node pool.

**************************************

First, you can confirm your node pool name and details by running the following command:

```powershell
Get-AksHciNodePool -clusterName akshciclus001
```

![Output of Get-AksHciNodePool](/media/get_akshcinodepool_wac.png "Output of Get-AksHciNoePool")

Then, to add a Windows node pool, run the following command:

```powershell
New-AksHciNodePool -clusterName akshciclus001 -osType windows -name windowsnodepool -count 1
```

This will create a new Windows node pool for your existing cluster, and deploy a single worker node into that cluster.  You can then scale the number of Linux worker nodes in your cluster by running the following command:

```powershell
Set-AksHciNodePool -clusterName akshciclus001 -name linuxnodepool -count 2
```

**************************

**NOTE** - You can also scale your Control Plane nodes for this particular cluster, however it has to be **scaled independently from the worker nodes** themselves. You can scale the Control Plane nodes using the command. Before you run this command however, check that you have an extra 16GB memory left of your HybridHost001 OS - if your host has been deployed with 64GB RAM, you may not have enough capacity for an additonal 2 Control Plane VMs.

```powershell
Set-AksHciCluster –Name akshciclus001 -controlPlaneNodeCount 3
```

**NOTE** - the control plane node count should be an **odd** number, such as 1, 3, 5 etc.


**************************

4. Once these steps have been completed, you can verify the details by running the following command:

```powershell
Get-AksHciCluster
```

![Output of Get-AksHciCluster](/media/get_akshcicluster_wac3.png "Output of Get-AksHciCluster")

To access this **akshciclus001** cluster using **kubectl** (which was installed on your host as part of the overall installation process), you'll first need the **kubeconfig file**.

5. To retrieve the kubeconfig file for the akshciclus001 cluster, you'll need to run the following command from your **administrative PowerShell**:

```powershell
Get-AksHciCredential -Name akshciclus001
dir $env:USERPROFILE\.kube
```

***********************
NOTE - if you receive an error that "kubectl is not recognized as the name of a cmdlet, function, script file or operable program", you can either log out of the Azure VM, then log back in, or run the following command from your PowerShell console: choco install kubernetes-cli, then close and re-open PowerShell.
***********************

Next Steps
-----------
In this step, you've successfully deployed the AKS on Azure Stack HCI management cluster using Windows Admin Center, optionally integrated with Azure Arc, and subsequently, deployed and scaled a Kubernetes cluster that you can move forward with to the next stage, in which you can deploy your applications.

* [**Part 6** - Explore AKS on Azure Stack HCI](/steps/6_ExploreAKSHCI.md "Explore AKS on Azure Stack HCI")

Product improvements
-----------
If, while you work through this guide, you have an idea to make the product better, whether it's something in Azure Stack HCI, AKS on Azure Stack HCI, Windows Admin Center, or the Azure Arc integration and experience, let us know! We want to hear from you!

For **Azure Stack HCI**, [Head on over to the Azure Stack HCI 21H2 Q&A forum](https://docs.microsoft.com/en-us/answers/topics/azure-stack-hci.html "Azure Stack HCI 21H2 Q&A"), where you can share your thoughts and ideas about making the technologies better and raise an issue if you're having trouble with the technology.

For **AKS on Azure Stack HCI**, [Head on over to our AKS on Azure Stack HCI 21H2 GitHub page](https://github.com/Azure/aks-hci/issues "AKS on Azure Stack HCI GitHub"), where you can share your thoughts and ideas about making the technologies better. If however, you have an issue that you'd like some help with, read on... 

Raising issues
-----------
If you notice something is wrong with this guide, such as a step isn't working, or something just doesn't make sense - help us to make this guide better!  Raise an issue in GitHub, and we'll be sure to fix this as quickly as possible!

If you're having an issue with Azure Stack HCI 21H2 **outside** of this guide, [head on over to the Azure Stack HCI 21H2 Q&A forum](https://docs.microsoft.com/en-us/answers/topics/azure-stack-hci.html "Azure Stack HCI 21H2 Q&A"), where Microsoft experts and valuable members of the community will do their best to help you.

If you're having a problem with AKS on Azure Stack HCI **outside** of this guide, make sure you post to [our GitHub Issues page](https://github.com/Azure/aks-hci/issues "GitHub Issues"), where Microsoft experts and valuable members of the community will do their best to help you.
