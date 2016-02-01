module KubernetesCookbook
  class KubernetesKubeconfig < ChefCompat::Resource
    use_automatic_resource_name

    property :location, String, default: lazy { kubeconfig_default_location }, required: true
    property :file_name, String, required: true
    property :clusters, Array, required: true
    property :users, Array, required: true
    property :contexts, Array, required: true
    property :current_context, String, required: true

    action :create do
      directory location do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end

      template ::File.join(location, file_name) do
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
