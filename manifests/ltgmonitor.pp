# helper class to setup a CEPH MON
# From http://paste.ubuntu.com/10627188/
# From IRC #ceph at oftc
# From user Be-El
#

class ceph::ltgmonitor ($mon_int) {

  $real_int_name = regsubst($mon_int, "\\.", "_")
  $addr_fact = "ipaddress_${real_int_name}"
  $addr = inline_template('<%= scope.lookupvar(@addr_fact) or "undefined" %>')

  if ($addr == "undefined") {
    fail("No IP address found for interface $mon_int")
  }

  include ceph::profile::params

  if (!defined(Class['Ceph::Profile::Params'])) {
    fail("Ceph param class not loaded")
  }

#  if (!defined(Apt::Source['ceph'])) {
#    class { 'ceph::repo':
#      release => $ceph::profile::params::release,
#    } 
#  }

  if (!defined(Yumrepo['ext-ceph'])) {
    class { 'ceph::ltg_repo':
      release => $ceph::profile::params::release,
    } 
  }

#     apt::source { 'ceph':
#     yumrepo { 'ext-ceph':


  if (!defined(Package['ceph'])) {
    class { 'ceph':
      fsid                      => $ceph::profile::params::fsid,
      authentication_type       => $ceph::profile::params::authentication_type,
      osd_pool_default_pg_num   => $ceph::profile::params::osd_pool_default_pg_num,
      osd_pool_default_pgp_num  => $ceph::profile::params::osd_pool_default_pgp_num,
      osd_pool_default_size     => $ceph::profile::params::osd_pool_default_size,
      osd_pool_default_min_size => $ceph::profile::params::osd_pool_default_min_size,
      mon_initial_members       => $ceph::profile::params::mon_initial_members,
      mon_host                  => $ceph::profile::params::mon_host,
      cluster_network           => $ceph::profile::params::cluster_network,
      public_network            => $ceph::profile::params::public_network,
    }
  }
  Class['Ceph::Profile::Params'] ->
  Class['Ceph::Ltg_repo'] ->
  Class['Ceph']

  Ceph_Config<| |> ->
  ceph::mon { $::hostname:
    authentication_type => $ceph::profile::params::authentication_type,
    key                 => $ceph::profile::params::mon_key,
    keyring             => $ceph::profile::params::mon_keyring,
    public_addr         => $addr,
  }

  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }

  # this supports providing the key manually
  if $ceph::profile::params::admin_key {
    ensure_resource('ceph::key','client.admin',
      {
        keyring_path => '/etc/ceph/ceph.client.admin.keyring',
        secret       => $ceph::profile::params::admin_key,
        mode         => $ceph::profile::params::admin_key_mode,
        cap_mon      => 'allow *',
        cap_osd      => 'allow *',
        cap_mds      => 'allow',
      })
  }

  if $ceph::profile::params::bootstrap_osd_key {
    ceph::key { 'client.bootstrap-osd':
      secret           => $ceph::profile::params::bootstrap_osd_key,
      keyring_path     => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
      cap_mon          => 'allow profile bootstrap-osd',
    }
  }

  if $ceph::profile::params::bootstrap_mds_key {
    ceph::key { 'client.bootstrap-mds':
      secret           => $ceph::profile::params::bootstrap_mds_key,
      keyring_path     => '/var/lib/ceph/bootstrap-mds/ceph.keyring',
      cap_mon          => 'allow profile bootstrap-mds',
    }
  }

  # the osds hosts might need to be accessible from other internal
  # hosts that do not belong to the ceph network
  # loosen the reverse path filter to allow these hosts to access
  # the osd
#  ensure_resource('sysctl::value',
#     ['net.ipv4.conf.default.rp_filter', 'net.ipv4.conf.all.rp_filter'],
#     { value => 2, target  => '/etc/sysctl.d/10-network-security.conf'})
}