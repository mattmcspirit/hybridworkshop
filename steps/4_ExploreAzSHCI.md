Explore the management of your Azure Stack HCI 20H2 environment
==============
Overview
-----------
With the Azure Stack HCI cluster deployed, you can now begin to explore some of the additional capabilities within Azure Stack HCI 20H2 and Windows Admin Center. We'll cover a few recommended activities below, to expose you to some of the key elements of the Windows Admin Center, but for the rest, we'll [direct you over to the official documentation](https://docs.microsoft.com/en-us/azure-stack/hci/ "Azure Stack HCI 20H2 documentation").

Contents
-----------
- [Overview](#overview)
- [Contents](#contents)
- [Create volumes for VMs](#create-volumes-for-vms)
- [Deploy a virtual machine](#deploy-a-virtual-machine)
- [Congratulations!](#congratulations)
- [Next Steps](#next-steps)
- [Product improvements](#product-improvements)
- [Raising issues](#raising-issues)

Create volumes for VMs
-----------
In this step, you'll create a volume on the Azure Stack HCI 20H2 cluster by using Windows Admin Center, and enable data deduplication and compression.

### Create a two-way mirror volume ###

1. Once logged into the **Windows Admin Center** on **HybridHost001**, click on your previously deployed cluster, **azshciclus.hybrid.local**
2. On the left hand navigation, under **Storage** select **Volumes**.  The central **Volumes** page shows you should have a single volume currently
3. On the Volumes page, select the **Inventory** tab, and then select **Create**
4. In the **Create volume** pane, leave the default for for the volume name, and leave **Resiliency** as **Two-way mirror**
5. In Size on HDD, specify **250GB** for the size of the volume
6. Under **More options**, tick the box for **Use deduplication and compression**
7. Under **Data type**, use the drop-down to select **Hyper-V**, then click **Create**.

![Create a volume on Azure Stack HCI 20H2](/media/wac_vm_storage_ga.png "Create a volume on Azure Stack HCI 20H2")

8. Creating the volume can take a few minutes. Notifications in the upper-right will let you know when the volume is created. The new volume appears in the Inventory list

![Volume created on Azure Stack HCI 20H2](/media/wac_vm_storage_deployed_ga.png "Volume created on Azure Stack HCI 20H2")

**NOTE** - You'll notice there there are 3 options for **Data type**; default, Hyper-V and Backup.  If you're interested in learning more about Deduplication in Azure Stack HCI 20H2, you should [refer to our documentation](https://docs.microsoft.com/en-us/windows-server/storage/data-deduplication/overview "Deduplication overview")

You now have a volume created and ready to accept workloads. Whilst we deployed the volume using the Windows Admin Center, you can also do the same through PowerShell. If you're interested in taking that approach, [check out the official docs that walk you through that process](https://docs.microsoft.com/en-us/azure-stack/hci/manage/create-volumes "Official documentation for creating volumes"). For more information on planning volumes with Azure Stack HCI 20H2, you should [refer to the official docs](https://docs.microsoft.com/en-us/azure-stack/hci/concepts/plan-volumes "Planning volumes for Azure Stack HCI 20H2").

Deploy a virtual machine
-----------
In this step, you'll deploy a VM onto your new volume, using Windows Admin Center.

### Create the virtual machine ###
You should still be over on **HybridHost001**, but if you're not, log into HybridHost001, and open the **Windows Admin Center**.

1. Once logged into the **Windows Admin Center** on **HybridHost001**, click on your previously deployed cluster, **azshciclus.hybrid.local**
2. On the left hand navigation, under **Compute** select **Virtual machines**.  The central **Virtual machines** page shows you no virtual machines deployed currently
3. On the **Virtual machines** page, select the **Inventory** tab, and then select **New**
4. In the **New virtual machine** pane, enter **VM001** for the name, and enter the following pieces of information, then click **Create**

    * Generation: **Generation 2 (Recommended)**
    * Host: **Leave as recommended**
    * Path: **C:\ClusterStorage\Volume01**
    * Virtual processors: **1**
    * Startup memory (GB): **0.5**
    * Network: **ComputeSwitch**
    * Storage: **Add, then Create an empty virtual hard disk** and set size to **5GB**
    * Operating System: **Install an operating system later**

5. The creation process will take a few moments, and once complete, **VM001** should show within the **Virtual machines view**
6. Click on the **VM** and then click **Start** - within moments, the VM should be running

![VM001 up and running](/media/wac_vm001_ga.png "VM001 up and running")

7. Click on **VM001** to view the properties and status for this running VM
8. Click on **Connect** - you may get a **VM Connect** prompt:

![Connect to VM001](/media/vm_connect_ga.png "Connect to VM001")

9. Click on **Go to Settings** and in the **Remote Desktop** pane, click on **Allow remote connections to this computer**, then **Save**
10. Click the **Back** button in your browser to return to the VM001 view, then click **Connect**, and when prompted with the certificate prompt, click **Connect** and enter appropriate credentials
11. There's no operating system installed here, so it should show a UEFI boot summary, but the VM is running successfully
12. Click **Disconnect**

You've successfully create a VM using the Windows Admin Center!

### Live migrate the virtual machine ###
The final step we'll cover is using Windows Admin Center to live migrate VM001 from it's current node, to an alternate node in the cluster.

1. Still within the **Windows Admin Center** on **HybridHost001**, under **Compute**, click on **Virtual machines**
2. On the **Virtual machines** page, select the **Inventory** tab
3. Under **Host server**, make a note of the node that VM001 is currently running on.  You may need to expand the column width to see the name
4. Next to **VM001**, click the tick box next to VM001, then click **More**.  You'll notice you can Clone, Domain Join and also Move the VM. Click **Move**

![Start Live Migration using Windows Admin Center](/media/wac_move_ga.png "Start Live Migration using Windows Admin Center")

5. In the **Move Virtual Machine** pane, ensure **Failover Cluster** is selected, and leave the default **Best available cluster node** to allow Windows Admin Center to pick where to migrate the VM to, then click **Move**
6. The live migration will then begin, and within a few seconds, the VM should be running on a different node.
7. On the left hand navigation, under **Compute** select **Virtual machines** to return to the VM dashboard view, which aggregates information across your cluster, for all of your VMs.

Congratulations!
-----------
You've reached the end of the first half of this workshop. So far, you have:

* Deployed/Configured a Windows Server 2019 Hyper-V host in Azure to run your nested sandbox environment
* Configured an Azure Stack HCI 20H2 cluster, in nested virtual machines
* Integrated the cluster with a cloud witness in Azure, and registered with Azure for billing
* Used Windows Admin Center to create a volume, then deploy and migrate a virtual machine.
* Set the foundation for further learning!

Great work!

Next Steps
-----------
In this step, you've successfully created a volume on your Azure Stack HCI 20H2 cluster to host virtual machines. In addition, you created a virtual machine and live migrated it using Windows Admin Center.

With this complete, you can now [deploy your AKS-HCI infrastructure](/steps/5_DeployAKSHCI.md "Deploy your AKS-HCI infrastructure")

This part of the workshop covers only a handful of key topics and capabilities that Azure Stack HCI 20H2 can provide.  In addition, we'd strongly advise you to check out some of the key areas below:

* [Explore Windows Admin Center](https://docs.microsoft.com/en-us/azure-stack/hci/get-started "Explore Windows Admin Center")
* [Manage virtual machines](https://docs.microsoft.com/en-us/azure-stack/hci/manage/vm "Manage virtual machines")
* [Add additional servers for management](https://docs.microsoft.com/en-us/azure-stack/hci/manage/add-cluster "Add additional servers for management")
* [Manage clusters](https://docs.microsoft.com/en-us/azure-stack/hci/manage/cluster "Manage clusters")
* [Create and manage storage volumes](https://docs.microsoft.com/en-us/azure-stack/hci/manage/create-volumes "Create and manage storage volumes")
* [Integrate Windows Admin Center with Azure](https://docs.microsoft.com/en-us/azure-stack/hci/manage/register-windows-admin-center "Integrate Windows Admin Center with Azure")
* [Monitor with with Azure Monitor](https://docs.microsoft.com/en-us/azure-stack/hci/manage/azure-monitor "Monitor with with Azure Monitor")
* [Integrate with Azure Site Recovery](https://docs.microsoft.com/en-us/azure-stack/hci/manage/azure-site-recovery "Integrate with Azure Site Recovery")

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