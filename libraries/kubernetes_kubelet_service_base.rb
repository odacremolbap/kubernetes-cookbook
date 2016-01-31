require 'kubernetes_service_base'

module KubernetesCookbook
  class  KubernetesKubeletServiceBase < KubernetesServiceBase
    require 'helper_kubernetes'
    include KubernetesHelpers::InstallationBinary

    use_automatic_resource_name

    property :manifest_dir, Hash, default: lazy { default_manifest_dir }

    def default_manifest_dir
      '/etc/kubernetes/manifests'
    end

  end
end
