class servinfo::thttpd()
{
  include rsyslog
	file
	{
		'thttpd.conf':
			ensure => file,
			path => '/etc/thttpd.conf',
			mode => 644,
			owner => root,
			group => root,
			source => 'puppet:///modules/servinfo/thttpdConf/thttpd.conf',
	}
	file
	{
		'servinfo.sudoers' :
			ensure => file,
			path => '/etc/sudoers.d/servinfo',
			mode => 440,
			owner => root,
			group => root,
			source => 'puppet:///modules/servinfo/servinfoSudoersFile',
	}
	file
	{
	  'rsyslog.thttpd':
      ensure => file,
      path => '/etc/rsyslog.d/thttpd.conf',
      mode => 440,
      owner => root,
      group => root,
      source => 'puppet:///modules/servinfo/rsyslog.thttpd',
	}

	File['rsyslog.thttpd']~>Service['rsyslog']

	package { 'servinfoUser': ensure => latest, }
	package { 'thttpd': ensure => latest, }
	service { 'thttpd': ensure => running, }

	Package['servinfoUser']
		->Package['thttpd']
		->File['thttpd.conf']
		->Service['thttpd']
}
