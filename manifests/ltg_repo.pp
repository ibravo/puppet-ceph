#   Modified from ceph::repo to include only LTG Katello repositories
#
#
# == Class: ceph::repo
#
# Configure ceph APT repo for Ceph
#
# === Parameters:
#
# [*ensure*] The ensure state for package ressources.
#  Optional. Defaults to 'present'.
#
# [*release*] The name of the Ceph release to install
#   Optional. Default to 'giant'.
#
# [*extras*] Install Ceph Extra APT repo.
#   Optional. Defaults to 'false'.
#
# [*fastcgi*] Install Ceph fastcgi apache module for Ceph
#   Optional. Defaults to 'false'
#
class ceph::ltg_repo (
  $ensure  = present,
  $release = 'giant',
  $extras  = false,
  $fastcgi = false,
) {
  case $::osfamily {
    'Debian': {
#      include ::apt

#      apt::key { 'ceph':
#        ensure     => $ensure,
#        key        => '17ED316D',
#        key_source => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
#      }

#      apt::source { 'ceph':
#        ensure   => $ensure,
#        location => "http://ceph.com/debian-${release}/",
#        release  => $::lsbdistcodename,
#        require  => Apt::Key['ceph'],
#        tag      => 'ceph',
#      }

      if $extras {

#        apt::source { 'ceph-extras':
#          ensure   => $ensure,
#          location => 'http://ceph.com/packages/ceph-extras/debian/',
#          release  => $::lsbdistcodename,
#          require  => Apt::Key['ceph'],
#        }

      }

      if $fastcgi {

#        apt::key { 'ceph-gitbuilder':
#          ensure     => $ensure,
#          key        => '6EAEAE2203C3951A',
#          key_server => 'keyserver.ubuntu.com',
#        }

#        apt::source { 'ceph-fastcgi':
#          ensure   => $ensure,
#          location => "http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-${::lsbdistcodename}-${::hardwaremodel}-basic/ref/master",
#          release  => $::lsbdistcodename,
#          require  => Apt::Key['ceph-gitbuilder'],
#        }

      }

#      Apt::Source<| tag == 'ceph' |> -> Package<| tag == 'ceph' |>
#      Exec['apt_update'] -> Package<| tag == 'ceph' |>
    }

    'RedHat': {
      $enabled = $ensure ? { 'present' => '1', 'absent' => '0', default => absent, }
#      yumrepo { 'ext-epel-6.8':
#        # puppet versions prior to 3.5 do not support ensure, use enabled instead
#        enabled    => $enabled,
#        descr      => 'External EPEL 6.8',
#        name       => 'ext-epel-6.8',
#        baseurl    => absent,
#        gpgcheck   => '0',
#        gpgkey     => absent,
#        mirrorlist => 'http://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
#        priority   => '20', # prefer ceph repos over EPEL
#        tag        => 'ceph',
#      }

      yumrepo { 'ext-ceph':
        # puppet versions prior to 3.5 do not support ensure, use enabled instead
        enabled    => $enabled,
        descr      => "External Ceph Testing",
        name       => "LTG-ceph-Testing",
        baseurl    => "http://katello.hq.ltg/pulp/repos/LTG_Federal/Library/custom/Ceph/Testing_el7_x86_64",
        gpgcheck   => '0',
        gpgkey     => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
        mirrorlist => absent,
        priority   => '10', # prefer ceph repos over EPEL
        tag        => 'ceph',
      }

      yumrepo { 'ext-ceph-noarch':
        # puppet versions prior to 3.5 do not support ensure, use enabled instead
        enabled    => $enabled,
        descr      => 'External Ceph noarch',
        name       => "LTG-ceph-Testing-noarch",
        baseurl    => "http://katello.hq.ltg/pulp/repos/LTG_Federal/Library/custom/Ceph/Testing_el7_noarch",
        gpgcheck   => '0',
        gpgkey     => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
        mirrorlist => absent,
        priority   => '10', # prefer ceph repos over EPEL
        tag        => 'ceph',
      }

      if $extras {

#        yumrepo { 'ext-ceph-extras':
#          enabled    => $enabled,
#          descr      => 'External Ceph Extras',
#          name       => 'ext-ceph-extras',
#          baseurl    => 'http://ceph.com/packages/ceph-extras/rpm/rhel6/$basearch',
#          gpgcheck   => '1',
#          gpgkey     => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
#          mirrorlist => absent,
#          priority   => '10', # prefer ceph repos over EPEL
#          tag        => 'ceph',
#        }

      }

      if $fastcgi {

        yumrepo { 'ext-ceph-fastcgi':
          enabled    => $enabled,
          descr      => 'FastCGI basearch packages for Ceph',
          name       => 'ext-ceph-fastcgi',
          baseurl    => 'http://gitbuilder.ceph.com/mod_fastcgi-rpm-rhel6-x86_64-basic/ref/master',
          gpgcheck   => '1',
          gpgkey     => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc',
          mirrorlist => absent,
          priority   => '20', # prefer ceph repos over EPEL
          tag        => 'ceph',
        }

      }

      Yumrepo<| tag == 'ceph' |> -> Package<| tag == 'ceph' |>

      # prefer ceph repos over EPEL
      package { 'yum-plugin-priorities':
        ensure => present,
      }

    }

    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only supports osfamily Debian and RedHat")
    }
  }
}
