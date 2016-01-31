module KubernetesCookbook
  class KubernetesInstallationBinary < ChefCompat::Resource
    require 'helper_kubernetes'
    include KubernetesHelpers::InstallationBinary

    resource_name :kubernetes_installation_binary

    property :version, String, default: lazy { default_version }, desired_state: false
    property :source, String, default: lazy { default_source }, desired_state: false

    default_action :create

    #########
    # actions
    #########


    action :create do

      # delete temp resources from previous executions
      file kubernetes_compressed_file do
        action :delete
        subscribes :delete, 'execute[extract kubernetes cmd]'
      end

      directory "#{file_cache_path}/kubernetes" do
        recursive true
        action :delete
        subscribes :delete, 'execute[extract kubernetes cmd]'
      end

      # download kubernetes
      remote_file 'download kubernetes' do
        path kubernetes_compressed_file
        source new_resource.source
        # checksum new_resource.checksum
        owner 'root'
        group 'root'
        mode '0755'
        action :create
        not_if {kubernetes_binaries_exists?}
      end

      execute 'extract kubernetes bundle' do
        command extract_kubernetes_bundle
        action :nothing
        subscribes :run, 'remote_file[download kubernetes]', :immediately
      end

      execute 'extract kubernetes cmd' do
        command extract_kubernetes_cmd
        action :nothing
        subscribes :run, 'execute[extract kubernetes bundle]', :immediately
      end

    end

    action :delete do

      kubernetes_path_to_binaries.each do |path|
        file ::File.expand_path(path) do
          action :delete
        end
      end

    end

    ################
    # helper methods
    ################

    # return expected compressed file downloaded from kubernetes URL
    def kubernetes_compressed_file
      "#{file_cache_path}/kubernetes-#{version}.tar.gz"
    end

    # return compressed file inside kubernetes compressed one, containing binaries
    def kubernetes_server_compressed_file
      'kubernetes/server/kubernetes-server-linux-amd64.tar.gz'
    end

    # return path to binaries inside kubernetes compressed
    def kubernetes_server_compressed_file_binaries
      (kube_commands 'kubernetes/server/bin').join(' ')
    end

    # return path to binaries
    def kubernetes_path_to_binaries
      kube_commands(kubernetes_bin_prefix)
    end

    def kubernetes_binaries_exists?
      kubernetes_path_to_binaries.each do |path|
        return false if !::File.exists?(path)
      end
      true
    end

    def kube_commands(prefix)
      commands = %w(kube-apiserver kube-controller-manager kube-proxy kube-scheduler kubectl kubelet)
      commands.map! { |c| ::File.join(prefix, c) }
    end

    def extract_kubernetes_bundle
      "tar xf #{kubernetes_compressed_file} -C #{file_cache_path} #{kubernetes_server_compressed_file}"
    end

    def extract_kubernetes_cmd
      "tar xf #{file_cache_path}/#{kubernetes_server_compressed_file} -C #{kubernetes_bin_prefix} #{kubernetes_server_compressed_file_binaries} --strip-components=3"
    end

    def default_version
      "v1.1.3"
    end

    def default_source
      "https://github.com/kubernetes/kubernetes/releases/download/#{version}/kubernetes.tar.gz"
    end
  end
end
