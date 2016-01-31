module KubernetesCookbook
  class KubernetesKubeletServiceManagerSystemd < KubernetesKubeletServiceBase
    use_automatic_resource_name

    # TODO: if using systemd
    provides :kubernetes_kubelet_service_manager

    property :requires, [Array, nil], default: lazy { service_default_requires }
    property :after, [Array, nil], default: lazy { service_default_after }
    property :service_options, Hash, default: lazy { service_default_options }
    property :service_user, String

    action :create do
      directory '/usr/libexec' do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end

      template '/lib/systemd/system/kubelet.service' do
        source 'lib/systemd/system/kubelet.service.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          requires: requires,
          after: after,
          environment: environment,
          service_user: service_user,
          manifest_dir: manifest_dir,
          daemon_start: kubelet_cmd,
          parameters: parameters,
          options: service_options
        )
        notifies :run, 'execute[systemctl daemon-reload]', :immediately
        notifies :restart, new_resource if auto_restart
        cookbook 'kubernetes'
        action :create
      end

      execute 'systemctl daemon-reload' do
        command '/bin/systemctl daemon-reload'
        action :nothing
      end

      # check container existence Kubernetes status -> grep Service: Api && Service: proxy
      # Kubernetes launch-Api --ipalloc-range
      # Kubernetes launch-proxy
      # export DOCKER_HOST=unix:///var/run/Kubernetes/Kubernetes.sock
    end

    action :start do
      service 'kubelet' do
        provider Chef::Provider::Service::Systemd
        supports status: true
        action [:enable, :start]
        only_if { ::File.exist?('/lib/systemd/system/kubelet.service') }
      end
    end

    action :stop do
      service 'kubelet' do
        provider Chef::Provider::Service::Systemd
        supports status: true
        action [:stop]
        only_if { ::File.exist?('/lib/systemd/system/kubelet.service') }
      end
    end

    action :restart do
      action_stop
      action_start
    end

    def service_default_requires
      [ ]
    end

    def service_default_after
      [ 'network.target' ]
    end

    def default_parameters
      {
        'address' => '0.0.0.0',
        'port'  => 10250
      }
    end

    def service_default_options
      {
      'Restart' => 'on-failure',
      'RestartSec' => 5
      }
    end

  end
end
