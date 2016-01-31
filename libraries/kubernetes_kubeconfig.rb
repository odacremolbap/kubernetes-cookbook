module KubernetesCookbook
  class KubernetesKubeconfig < ChefCompat::Resource
    use_automatic_resource_name

    provides :kubernetes_kubelet_service_manager
    property :default_location, String, default: lazy { kubeconfig_default_location }, required: true
    property :file_name, String, required: true
    property :clusters, Hash, required: true
    property :users, Hash, required: true
    property :contexts, Hash, required: true
    property :current_context, String, required: true

    action :create do
      directory default_location do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end

      template ::File.join(default_location, file_name) do
        source 'etc/default/kubeconfig.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          clusters: clusters,
          users: users,
          contexts: contexts,
          current_context: current_context
        )
        cookbook 'kubernetes'
        action :create
      end

    end

    def kubeconfig_default_location
      '/etc/default/'
    end

  end
end
