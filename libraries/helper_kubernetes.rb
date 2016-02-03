module KubernetesCookbook
  module KubernetesHelpers
    module InstallationBinary

      def file_cache_path
        Chef::Config[:file_cache_path]
      end

      def kubernetes_bin_prefix
        '/usr/local/bin'
      end

      def apiserver_binary_name
        'kube-apiserver'
      end

      def kubelet_binary_name
        'kubelet'
      end

      def scheduler_binary_name
        'kube-scheduler'
      end

      def controller_binary_name
        'kube-controller-manager'
      end

      def apiserver_cmd
        ::File.join(kubernetes_bin_prefix, apiserver_binary_name)
      end

      def kubelet_cmd
        ::File.join(kubernetes_bin_prefix, kubelet_binary_name)
      end

      def scheduler_cmd
        ::File.join(kubernetes_bin_prefix, scheduler_binary_name)
      end

      def controller_cmd
        ::File.join(kubernetes_bin_prefix, controller_binary_name)
      end

    end
  end
end
