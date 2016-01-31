module KubernetesCookbook
  class KubernetesServiceBase < ChefCompat::Resource
    require 'helper_kubernetes'
    include KubernetesHelpers

    Boolean = property_type(
      is: [true, false],
      default: false
    ) unless defined?(Boolean)


    property :environment, Hash, default: lazy { default_environment }
    property :parameters, Hash, default: lazy {default_parameters }
    property :auto_restart, Boolean, default: false

    def default_environment
      {}
    end

    def default_parameters
      {}
    end

  end
end
