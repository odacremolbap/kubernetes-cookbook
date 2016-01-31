module KubernetesCookbook
  class KubernetesApiServiceManagerSystemd < KubernetesApiServiceBase
    use_automatic_resource_name

    # TODO: if using systemd
    provides :kubernetes_api_service_manager

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

      template '/lib/systemd/system/kube-apiserver.service' do
        source 'lib/systemd/system/kube-apiserver.service.erb'
        owner 'root'
        group 'root'
        mode '0644'
        variables(
          requires: requires,
          after: after,
          environment: environment,
          service_user: service_user,
          daemon_start: apiserver_cmd,
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

    end

    action :start do
      service 'kube-apiserver' do
        provider Chef::Provider::Service::Systemd
        supports status: true
        action [:enable, :start]
        only_if { ::File.exist?('/lib/systemd/system/kube-apiserver.service') }
      end
    end

    action :stop do
      service 'kube-apiserver' do
        provider Chef::Provider::Service::Systemd
        supports status: true
        action [:stop]
        only_if { ::File.exist?('/lib/systemd/system/kube-apiserver.service') }
      end
    end

    action :restart do
      action_stop
      action_start
    end

    def service_default_requires
      [ 'etcd.service' ]
    end

    def service_default_after
      [ 'network.target' ]
    end

    def default_parameters
      {
        'bind-address' => '0.0.0.0',
        'secure-port' => 6443
      }
    end

    def service_default_options
      {
      'Restart' => 'on-failure',
      'Type' => 'notify',
      'LimitNOFILE' => 65536
      }
    end

  end
end
