# == class fluentd::packages
class fluentd::packages (
    $package_name = $fluentd::package_name,
    $install_repo = $fluentd::install_repo,
    $package_ensure = $fluentd::package_ensure
){
    if $install_repo {
        case $::osfamily {
            'redhat': {
                class{'fluentd::install_repo::yum':
                    before => Package[$package_name],
                }
            }
            'debian': {
                class{'fluentd::install_repo::apt':
                    before => Package[$package_name],
                }
            }
            default: {
                fail("Unsupported osfamily ${::osfamily}")
            }
        }
    }
    package { "$package_name":
        ensure => $package_ensure
    }

# extra bits... why this is required isn't quite clear.
    case $::osfamily {
        'debian': {
            case $package_ensure {
                'present', 'absent', 'installed', 'purged', 'held', 'latest': {
                    package{[
                        'libxslt1.1',
                        'libyaml-0-2',
                    ]:
                        before => Package[$package_name],
                        ensure => $package_ensure
                    }
                }
                default: {
                    # specific version of td-agent asked for, just make
                    # sure that these two packages are installed
                    package{[
                        'libxslt1.1',
                        'libyaml-0-2',
                    ]:
                        before => Package[$package_name],
                        ensure => present
                    }
                }
            }
            exec {'add user td-agent to group adm':
                provider => shell,
                unless => '/bin/grep -q "adm\S*td-agent" /etc/group',
                command => '/usr/sbin/usermod -aG adm td-agent',
                subscribe => Package[$package_name],
            }
        }
        default: {
            info("No required fluentd::packages extra bits for ${::osfamily}")
        }
    }

}
