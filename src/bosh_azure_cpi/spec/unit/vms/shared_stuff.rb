# frozen_string_literal: true

# The following default configurations are shared. If one case needs a specific configuration, it should overwrite it.
shared_context 'shared stuff for vm managers' do
  # Parameters of VMManager.initialize
  let(:azure_config) { mock_azure_config }
  let(:azure_config_managed) do
    mock_azure_config_merge(
      'use_managed_disks' => true
    )
  end
  let(:azure_config_azure_stack) do
    mock_azure_config_merge(
      'environment' => 'AzureStack'
    )
  end
  let(:azure_config_to_keep_failed_vms) do
    mock_azure_config_merge(
      'keep_failed_vms' => true
    )
  end
  let(:azure_config_managed_to_keep_failed_vms) do
    mock_azure_config_merge(
      'use_managed_disks' => true,
      'keep_failed_vms'   => true
    )
  end
  let(:azure_config_vmss) do
    mock_azure_config_merge(
      'use_managed_disks' => true,
      'config_disk' => {
        'enabled' => true
      },
      'vmss' => {
        'enabled' => true
      }
    )
  end
  let(:props_factory) do
    Bosh::AzureCloud::Config.instance.update(mock_cloud_options['properties'])
    Bosh::AzureCloud::PropsFactory.new(
      Bosh::AzureCloud::Config.instance.azure
    )
  end
  let(:azure_config_use_config_disk) do
    mock_azure_config_merge(
      'use_managed_disks' => true,
      'config_disk' => {
        'enabled' => true
      }
    )
  end
  let(:registry_endpoint) { mock_registry.endpoint }
  let(:disk_manager) { instance_double(Bosh::AzureCloud::DiskManager) }
  let(:disk_manager2) { instance_double(Bosh::AzureCloud::DiskManager2) }
  let(:azure_client) { instance_double(Bosh::AzureCloud::AzureClient) }
  let(:storage_account_manager) { instance_double(Bosh::AzureCloud::StorageAccountManager) }
  let(:stemcell_manager) { instance_double(Bosh::AzureCloud::StemcellManager) }
  let(:stemcell_manager2) { instance_double(Bosh::AzureCloud::StemcellManager2) }
  let(:light_stemcell_manager) { instance_double(Bosh::AzureCloud::LightStemcellManager) }
  let(:blob_manager) { instance_double(Bosh::AzureCloud::BlobManager) }
  let(:config_disk_manager) { Bosh::AzureCloud::ConfigDiskManager.new(blob_manager, disk_manager2, storage_account_manager) }
  # VM manager for unmanaged disks
  let(:vm_manager) { Bosh::AzureCloud::VMManager.new(azure_config, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager) }
  # VM manager for managed disks
  let(:vm_manager2) { Bosh::AzureCloud::VMManager.new(azure_config_managed, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager) }
  # VM manager for azure stack
  let(:vm_manager_azure_stack) do
    Bosh::AzureCloud::VMManager.new(
      azure_config_azure_stack, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager
    )
  end
  let(:vm_manager_to_keep_failed_vms) { Bosh::AzureCloud::VMManager.new(azure_config_to_keep_failed_vms, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager) }
  let(:vm_manager2_to_keep_failed_vms) { Bosh::AzureCloud::VMManager.new(azure_config_managed_to_keep_failed_vms, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager) }
  let(:vmss_manager) { Bosh::AzureCloud::VMSSManager.new(azure_config_vmss, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager, config_disk_manager) }
  let(:vmss_manager_to_keep_failed_vms) { Bosh::AzureCloud::VMSSManager.new(azure_config_managed_to_keep_failed_vms, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager, config_disk_manager) }
  let(:vm_manager_adaptive) { Bosh::AzureCloud::VMManagerAdaptive.new(azure_config_vmss, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager, config_disk_manager) }
  let(:vm_manager_adaptive_vmss_disabled) { Bosh::AzureCloud::VMManagerAdaptive.new(azure_config, registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager, config_disk_manager) }

  let(:idle_timeout) { 20 }
  # VM manager for public ip
  let(:vm_manager_for_pip) do
    Bosh::AzureCloud::VMManager.new(
      mock_azure_config_merge(
        'pip_idle_timeout_in_minutes' => idle_timeout
      ), registry_endpoint, disk_manager, disk_manager2, azure_client, storage_account_manager, stemcell_manager, stemcell_manager2, light_stemcell_manager
    )
  end
  # Parameters of create
  let(:location) { 'fake-location' }
  let(:agent_id) { 'fake-agent-id' }
  let(:stemcell_id) { 'fake-stemcell-id' }
  let(:bosh_vm_meta) { Bosh::AzureCloud::BoshVMMeta.new(agent_id, stemcell_id) }
  let(:stemcell_info) { instance_double(Bosh::AzureCloud::Helpers::StemcellInfo) }

  let(:vm_properties) do
    {
      'instance_type'         => 'Standard_D1',
      'storage_account_name'  => 'dfe03ad623f34d42999e93ca',
      'caching'               => 'ReadWrite',
      'load_balancer'         => 'fake-lb-name',
      'application_gateway'   => 'fake-ag-name'
    }
  end
  let(:vm_props) do
    props_factory.parse_vm_props(vm_properties)
  end

  let(:network_configurator) { instance_double(Bosh::AzureCloud::NetworkConfigurator) }
  let(:env) { {} }
  let(:empty_env) { {} }
  let(:env_with_group) do
    {
      'bosh' => {
        'group' => 'instance_group_1'
      }
    }
  end
  let(:env_with_long_name_group) do
    {
      'bosh' => {
        'group' => 'lonnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnngname'
      }
    }
  end

  # Security Group
  let(:empty_security_group) { Bosh::AzureCloud::SecurityGroup.new(nil, nil) }

  # Instance ID
  let(:resource_group_name) { 'fake-resource-group' }
  let(:vm_name) { agent_id }
  let(:vmss_name) { 'fake-vmss-name' }
  let(:vmss_instance_id) { '0' }
  let(:storage_account_name) { 'fake-storage-acount-name' }
  let(:instance_id_string) { 'fake-instance-id' }
  let(:instance_id) { instance_double(Bosh::AzureCloud::VMInstanceId) }
  let(:instance_id_vmss) { Bosh::AzureCloud::VMSSInstanceId.create(resource_group_name, agent_id, vmss_name, vmss_instance_id) }
  let(:meta_data) { {} }

  before do
    allow(instance_id).to receive(:vm_name)
      .and_return(vm_name)
    allow(instance_id).to receive(:storage_account_name)
      .and_return(storage_account_name)
    allow(instance_id).to receive(:to_s)
      .and_return(instance_id_string)
    allow(vm_manager).to receive(:get_storage_account_from_vm_properties)
      .and_return(name: storage_account_name)
    allow(vm_manager2).to receive(:get_storage_account_from_vm_properties)
      .and_return(name: storage_account_name)
    allow(vm_manager_azure_stack).to receive(:get_storage_account_from_vm_properties)
      .and_return(name: storage_account_name)
    allow(vm_manager_for_pip).to receive(:get_storage_account_from_vm_properties)
      .and_return(name: storage_account_name)
  end

  # Stemcell
  let(:stemcell_uri) { 'fake-uri' }
  let(:os_type) { 'fake-os-type' }
  before do
    allow(stemcell_info).to receive(:uri)
      .and_return(stemcell_uri)
    allow(stemcell_info).to receive(:os_type)
      .and_return(os_type)
    allow(stemcell_info).to receive(:is_windows?)
      .and_return(false)
    allow(stemcell_info).to receive(:image_size)
      .and_return(nil)
    allow(stemcell_info).to receive(:is_light_stemcell?)
      .and_return(false)
  end

  # AzureClient
  let(:subnet) { double('subnet') }
  let(:default_security_group) do
    {
      name: MOCK_DEFAULT_SECURITY_GROUP,
      id: 'fake-nsg-id'
    }
  end
  let(:load_balancer) do
    {
      name: 'fake-lb-name'
    }
  end
  let(:application_gateway) do
    {
      name: 'fake-ag-name'
    }
  end
  before do
    allow(Bosh::AzureCloud::AzureClient).to receive(:new)
      .and_return(azure_client)
    allow(azure_client).to receive(:get_network_subnet_by_name)
      .with(MOCK_RESOURCE_GROUP_NAME, 'fake-virtual-network-name', 'fake-subnet-name')
      .and_return(subnet)
    allow(azure_client).to receive(:get_network_security_group_by_name)
      .with(MOCK_RESOURCE_GROUP_NAME, MOCK_DEFAULT_SECURITY_GROUP)
      .and_return(default_security_group)
    allow(azure_client).to receive(:get_load_balancer_by_name)
      .with(MOCK_RESOURCE_GROUP_NAME, vm_properties['load_balancer'])
      .and_return(load_balancer)
    allow(azure_client).to receive(:get_application_gateway_by_name)
      .with(vm_properties['application_gateway'])
      .and_return(application_gateway)
    allow(azure_client).to receive(:get_public_ip_by_name)
      .with(MOCK_RESOURCE_GROUP_NAME, vm_name)
      .and_return(nil)
    allow(azure_client).to receive(:get_resource_group)
      .and_return({})
  end

  # Network

  let(:vip_network) { instance_double(Bosh::AzureCloud::VipNetwork) }
  let(:manual_network) { instance_double(Bosh::AzureCloud::ManualNetwork) }
  let(:dynamic_network) { instance_double(Bosh::AzureCloud::DynamicNetwork) }
  before do
    allow(network_configurator).to receive(:vip_network)
      .and_return(vip_network)
    allow(network_configurator).to receive(:networks)
      .and_return([manual_network, dynamic_network])
    allow(network_configurator).to receive(:default_dns)
      .and_return('fake-dns')

    allow(vip_network).to receive(:resource_group_name)
      .and_return('fake-resource-group')
    allow(azure_client).to receive(:list_public_ips)
      .and_return([{
                    ip_address: 'public-ip'
                  }])
    allow(vip_network).to receive(:public_ip)
      .and_return('public-ip')

    allow(manual_network).to receive(:resource_group_name)
      .and_return(MOCK_RESOURCE_GROUP_NAME)
    allow(manual_network).to receive(:virtual_network_name)
      .and_return('fake-virtual-network-name')
    allow(manual_network).to receive(:subnet_name)
      .and_return('fake-subnet-name')
    allow(manual_network).to receive(:private_ip)
      .and_return('private-ip')
    allow(manual_network).to receive(:security_group)
      .and_return(empty_security_group)
    allow(manual_network).to receive(:application_security_groups)
      .and_return([])
    allow(manual_network).to receive(:ip_forwarding)
      .and_return(false)
    allow(manual_network).to receive(:accelerated_networking)
      .and_return(false)

    allow(dynamic_network).to receive(:resource_group_name)
      .and_return(MOCK_RESOURCE_GROUP_NAME)
    allow(dynamic_network).to receive(:virtual_network_name)
      .and_return('fake-virtual-network-name')
    allow(dynamic_network).to receive(:subnet_name)
      .and_return('fake-subnet-name')
    allow(dynamic_network).to receive(:security_group)
      .and_return(empty_security_group)
    allow(dynamic_network).to receive(:application_security_groups)
      .and_return([])
    allow(dynamic_network).to receive(:ip_forwarding)
      .and_return(false)
    allow(dynamic_network).to receive(:accelerated_networking)
      .and_return(false)
  end

  # Disk
  let(:os_disk_name) { 'fake-os-disk-name' }
  let(:ephemeral_disk_name) { 'fake-ephemeral-disk-name' }
  let(:os_disk) do
    {
      disk_name: 'fake-disk-name',
      disk_uri: 'fake-disk-uri',
      disk_size: 'fake-disk-size',
      disk_caching: 'fake-disk-caching'
    }
  end
  let(:ephemeral_disk) do
    {
      disk_name: 'fake-disk-name',
      disk_uri: 'fake-disk-uri',
      disk_size: 'fake-disk-size',
      disk_caching: 'fake-disk-caching'
    }
  end
  let(:os_disk_managed) do
    {
      disk_name: 'fake-disk-name',
      disk_size: 'fake-disk-size',
      disk_caching: 'fake-disk-caching'
    }
  end
  let(:ephemeral_disk_managed) do
    {
      disk_name: 'fake-disk-name',
      disk_size: 'fake-disk-size',
      disk_caching: 'fake-disk-caching'
    }
  end
  let(:data_disk_id) { 'bosh-disk-data-0a1171c3-d9a6-4a04-96cb-e422c1f49a7b-None' }
  let(:data_disk_obj) { Bosh::AzureCloud::CloudIdParser.parse(data_disk_id, resource_group_name) }
  let(:config_disk_id) { 'bosh-cfg-disk-0a1171c3-d9a6-4a04-96cb-e422c1f49a7c-None' }
  let(:config_disk_obj) { Bosh::AzureCloud::CloudIdParser.parse(config_disk_id, resource_group_name) }
  let(:config_disk_resource_id) { 'fake_disk_resource_id' }
  let(:config_disk_resource) { { id: config_disk_resource_id } }
  before do
    allow(disk_manager).to receive(:delete_disk)
      .and_return(nil)
    allow(disk_manager).to receive(:generate_os_disk_name)
      .and_return(os_disk_name)
    allow(disk_manager).to receive(:generate_ephemeral_disk_name)
      .and_return(ephemeral_disk_name)
    allow(disk_manager).to receive(:os_disk)
      .and_return(os_disk)
    allow(disk_manager).to receive(:ephemeral_disk)
      .and_return(ephemeral_disk)
    allow(disk_manager).to receive(:delete_vm_status_files)
      .and_return(nil)

    allow(disk_manager2).to receive(:generate_os_disk_name)
      .and_return(os_disk_name)
    allow(disk_manager2).to receive(:generate_ephemeral_disk_name)
      .and_return(ephemeral_disk_name)
    allow(disk_manager2).to receive(:os_disk)
      .and_return(os_disk_managed)
    allow(disk_manager2).to receive(:ephemeral_disk)
      .and_return(ephemeral_disk_managed)
  end

  # Network Interface
  let(:network_interface) do
    {
      name: 'foo'
    }
  end
  before do
    allow(azure_client).to receive(:create_network_interface)
    allow(azure_client).to receive(:get_network_interface_by_name)
      .and_return(network_interface)
  end
end
