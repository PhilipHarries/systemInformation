class servinfo::cswlighttpd()
{
	file
	{
		'lighttpd.conf':
			ensure => file,
			path => '/etc/opt/csw/lighttpd.conf',
			mode => 644,
			owner => root,
			group => root,
			source => 'puppet:///modules/servinfo/lighttpdConf/lighttpd-solaris.conf',
	}


	package { 'CSWlighttpd': ensure => latest, provider => 'pkgutil', }
	service { 'cswlighttpd': ensure => running, }
	File['lighttpd.conf']~>Service['cswlighttpd']
	File['lighttpd.conf']->Package['CSWlighttpd']->Service['cswlighttpd']
}
