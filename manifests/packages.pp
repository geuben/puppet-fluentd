class fluentd::packages {

  case $::osfamily {
    'redhat': {
      fail("RedHat and CentOS are not supported yet. Waiting for your pullrequest")
    }
    'debian': {

      # http://packages.treasure-data.com/debian/pool/contrib/t/td-agent/
      apt::source { 'treasure-data':
        location    => "http://packages.treasure-data.com/debian",
        release     => "lucid",
        repos       => "contrib",
        include_src => false,
      }->
      package{[
        'libxslt1.1',
        'libyaml-0-2',
        'td-agent'
      ]:
        ensure => present,
      }
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }


}