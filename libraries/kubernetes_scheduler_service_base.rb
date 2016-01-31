require 'kubernetes_service_base'

module KubernetesCookbook
  class  KubernetesSchedulerServiceBase < KubernetesServiceBase
    require 'helper_kubernetes'
    include KubernetesHelpers::InstallationBinary

    use_automatic_resource_name

  end
end
