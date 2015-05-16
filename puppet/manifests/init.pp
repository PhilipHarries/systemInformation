class servinfo
	(
		$servInfoClass = 'node',
		$envName = 'unset',
	)
{

	case $::osfamily
	{
		'RedHat' :
		{

			include servinfo::thttpd


			case $servInfoClass
			{
				'node' :
				{

							#notify { 'servInfoNodeMessage' : message => 'this is a servInfo node', }

				}
				'master' :
				{
							#notify { 'servInfoServerMessage' : message => 'this is a servInfo server', }

							file
							{
								'whatWhereRaw.pl' :
									ensure =>  file,
									path	=>	'/var/servinfo/whatWhereRaw.pl',
									mode	=>	555,
									owner	=>	servinfo,
									group	=>	servinfo,
									source	=> 'puppet:///modules/servinfo/central/whatWhereRaw.pl',
							}

							cron
							{
							'whatWhereRaw':
								command	=>	'sleep 15 && /var/servinfo/whatWhereRaw.pl',
								user	=>	'servinfo',
								minute	=>	'*',
							}

							file
							{
								'addDetail.pl' :
									ensure =>  file,
									path	=>	'/var/servinfo/addDetail.pl',
									mode	=>	555,
									owner	=>	servinfo,
									group	=>	servinfo,
									source	=> 'puppet:///modules/servinfo/central/addDetail.pl',
							}

							cron
							{
							'addDetail':
								command	=>	'sleep 40 && /var/servinfo/addDetail.pl',
								user	=>	'servinfo',
								minute	=>	'*/5',
							}

              file
              {
                'dispNice.ksh' :
                  ensure =>  file,
                  path  =>  '/var/servinfo/dispNice.ksh',
                  mode  =>  555,
                  owner =>  servinfo,
                  group =>  servinfo,
                  source  => 'puppet:///modules/servinfo/central/dispNice.ksh',
              }

              cron
              {
              'dispNice':
                command =>  'sleep 100 && /var/servinfo/dispNice.ksh /var/servinfo/servInfo/content/vmRawDetails',
                user  =>  'servinfo',
                minute  =>  '*/5',
              }

              file
              {
                'system_details':
                  ensure => directory,
                  owner => 'servinfo',
                  group => 'servinfo',
                  path => '/var/servinfo/servInfo/content/system_details',
                  source => 'puppet:///modules/servinfo/system_details',
                  recurse => true,
              }

              cron
              {
                'refreshDetails':
                  command => 'rm -f /var/servinfo/servInfo/content/system_details/*/os.txt /var/servinfo/servInfo/content/system_details/*/type.txt',
                  user => servinfo,
                  minute => '0',
              }

              #notify { 'servInfoServerMessage1' : message => 'going to create system_details...', }
              #notify { 'servInfoServerMessage2' : message => 'created system_details!', }
              #Notify['servInfoServerMessage1']->File['system_details']->Notify['servInfoServerMessage2']



				      cron
				      {
				        'collateInfo.run':
				          ensure => absent,
				          command => '/var/servinfo/servInfo/content/collateInfo.run',
				          user => 'servinfo',
				          minute => '*/4',
				      }

							file
							{
								'siteInfo.pl':
									ensure =>  file,
									path	=>	'/var/servinfo/servInfo/content/siteInfo.pl',
									mode	=>	555,
									owner	=>	servinfo,
									group	=>	servinfo,
									source	=>	'puppet:///modules/servinfo/central/siteInfo.pl',
							}

							file
							{
								'vmStats.pl':
									ensure =>  file,
									path	=>	'/var/servinfo/servInfo/content/vmStats.pl',
									mode	=>	755,
									owner	=>	servinfo,
									group	=>	servinfo,
									source	=>	'puppet:///modules/servinfo/central/vmStats.pl',
							}

              file
              {
                'vmStats.html':
                  ensure => file,
                  path => '/var/servinfo/servInfo/content/vmStats.html',
                  mode => 644,
                  owner => servinfo,
                  group => servinfo,
                  source => 'puppet:///modules/servinfo/central/vmStats.html',
              }

              file
              {
                'vmStats.js':
                  ensure => file,
                  path => '/var/servinfo/servInfo/content/vmStats.js',
                  mode => 644,
                  owner => servinfo,
                  group => servinfo,
                  source => 'puppet:///modules/servinfo/central/vmStats.js',
              }

              file
              {
                'd3.v3.min.js':
                  ensure => file,
                  path => '/var/servinfo/servInfo/content/d3.v3.min.js',
                  mode => 644,
                  owner => servinfo,
                  group => servinfo,
                  source => 'puppet:///modules/servinfo/lib/d3.v3.min.js',
              }

							file
							{
								'vmstats.css':
		              ensure  =>  file,
		 							path	=>	'/var/servinfo/servInfo/content/vmstats.css',
									mode	=>	444,
									owner	=>	servinfo,
									group	=>	servinfo,
									source	=>	'puppet:///modules/servinfo/central/vmstats.css',
							}



				}
				default:
				{
							#notify { 'servInfoWarn1' : message => 'could not classify servinfo server type', }
							#notify { 'servInfoWarn2' : message => "servinfo server type was ${servInfoClass}", }
				}
			}	# case servInfoClass



			file{ 'setMotd.sh' :
						ensure => file,
						path => '/var/servinfo/setMotd.sh',
						mode => 555,
						owner => root,
						group => root,
						source => 'puppet:///modules/servinfo/setMotd.sh',
					}

			cron
			{
				'setMotd.sh':
					command => '/var/servinfo/setMotd.sh',
					user => 'root',
					minute => '*/15',
			}



			case $::virtual
			{
				'physical' :
				{
					file
					{
						'genVMList.ksh':
							ensure => file,
							path => '/var/servinfo/genVMList.ksh',
							mode => 555,
							owner => servinfo,
							group => servinfo,
							source => 'puppet:///modules/servinfo/getVMList/getVMList-linux.ksh',
					}

					file
					{
						'vmusage.pl':
							ensure => file,
							path => '/var/servinfo/servInfo/content/vmusage.pl',
							mode => 555,
							owner => servinfo,
							group => servinfo,
							source => 'puppet:///modules/servinfo/vmusage.pl',
					}

					cron
					{
						'generateVMList':
							command => '/var/servinfo/genVMList.ksh',
							user => 'servinfo',
							minute => '*',
					}
				}
			}

      file
      {
        'type.txt':
          ensure => file,
          path => '/var/servinfo/servInfo/content/type.txt',
          owner => servinfo,
          group => servinfo,
          mode => 444,
          content => template('servinfo/type.txt.erb'),
      }

			file
			{
				'editInfo.pl':
					ensure =>  file,
					path	=>	'/var/servinfo/servInfo/content/editInfo.pl',
					mode	=>	555,
					owner	=>	servinfo,
					group	=>	servinfo,
					source	=>	'puppet:///modules/servinfo/editInfo.pl',
			}

			file
			{
				'os.pl':
					ensure =>  file,
					path	=>	'/var/servinfo/servInfo/content/os.pl',
					mode	=>	555,
					owner	=>	servinfo,
					group	=>	servinfo,
					content => template('servinfo/os.pl.erb'),
			}
			file
			{
				'type.pl':
					ensure =>  file,
					path	=>	'/var/servinfo/servInfo/content/type.pl',
					mode	=>	555,
					owner	=>	servinfo,
					group	=>	servinfo,
					source	=>	'puppet:///modules/servinfo/type.pl',
			}

			file
			{
				'vmlist.pl':
					ensure =>  file,
					path	=>	'/var/servinfo/servInfo/content/vmlist.pl',
					mode	=>	555,
					owner	=>	servinfo,
					group	=>	servinfo,
					source	=>	'puppet:///modules/servinfo/vmlist.pl',
			}

			file
			{
				'this.css':
					ensure =>  file,
					path	=>	'/var/servinfo/servInfo/content/this.css',
					mode	=>	444,
					owner	=>	servinfo,
					group	=>	servinfo,
					source	=>	'puppet:///modules/servinfo/this.css',
			}

      file
      {
        'collateVMInfo.pl':
        ensure  =>  file,
        path  =>  '/var/servinfo/collateVMInfo.pl',
        mode  =>  755,
        owner =>  servinfo,
        group =>  servinfo,
        source  =>  'puppet:///modules/servinfo/collateVMInfo.pl'
      }

      file
      {
        'unwantedCollateInfo.pl':
        ensure  =>  absent,
        path  =>  '/var/servinfo/collateInfo.pl',
      }
      cron
      {
        'collateInfo':
          ensure => absent,
          user => ['root','servinfo'],
          command => '/var/servinfo/collateInfo.pl',
          minute => '*',
      }
      cron
      {
        'collateVMInfo':
          command => '/var/servinfo/collateVMInfo.pl',
          user => 'servinfo',
          minute => '*',
      }

      # add in server information to server itself
      case $::hostname
      {
        'appbl06p-db1' :  { $thisHostName = 'appbl06pdb1.gsl.lon' }
        'appbl10p-db2' :  { $thisHostName = 'appbl10pdb2.gsl.lon' }
        # 'gsldev69' : { $thisHostName = 'gsldev69.gsl.fab.eng.sita.aero' }
        default : { $thisHostName = $::fqdn }
      }
      #notify{'thisHostNameMsg0': message => "hostname is ${::hostname}.", }
      #notify{'thisHostNameMsg1': message => "this host will lookup ${thisHostName}.", }

      file
      {
        "${::fqdn}_notes.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/notes.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${thisHostName}/notes.txt",
      }
      file
      {
        "${::fqdn}_prefix.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/prefix.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${thisHostName}/prefix.txt",
      }
      file
      {
        "${::fqdn}_project.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/project.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${thisHostName}/project.txt",
      }
      file
      {
        "${::fqdn}_usage.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/usage.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${thisHostName}/usage.txt",
      }
      file
      {
        "${::fqdn}_contact.txt":
          ensure => file,
          path => '/var/servinfo/servInfo/content/contact.txt',
          mode => 644,
          owner => servinfo,
          group => servinfo,
          source => "puppet:///modules/servinfo/system_details/${thisHostName}/contact.txt",
       }

		}

		'windows':
		{
			#notify { 'servInfoWinMsg1' : message => 'this is a windows server', }
			require windows_repo
			#notify{ '7zipStartInstall' : message => 'Attempting install of 7zip...', }
      file
      {
        '7z920.msi':
                ensure => file,
                path => 'c:\windowsRepo\windows\package_distro\7z920.msi',
                owner => 'Everyone',
                mode => 777,
      }
			package
			{
				'7zip':
				ensure		=> 'installed',
				source		=> 'c:\windowsRepo\windows\package_distro\7z920.msi',
				require =>  File['7z920.msi'],
			}
			#Notify['7zipStartInstall'] -> Package['7zip']
			#notify { '7zipInstalled' : message => '7zip installed', }
			#Package['7zip']->Notify['7zipInstalled']
			#notify { 'webDirCreated' : message => 'c:\web created', }
      file
      {
        'web_dir':
                ensure => directory,
                path => 'c:/web',
                owner => 'Everyone',
                mode => 755,
      }
			#File['web_dir']->Notify['webDirCreated']
			case $::architecture
			{
				'x86' :
				{
					#notify { '7zaCopied' : message => '7za copied to Program Files', }
					exec
					{
						 'cmd /c copy /Y c:\windowsRepo\windows\package_distro\7za.exe "c:\Program Files\7-Zip"':
						path	=>	$::path,
						require	=>	Package['7zip'],
						#before	=>	Notify['7zaCopied'],
						creates => 'c:\Program Files\7-Zip\7za.exe',
					}
					package
					{
					 'StrawberryPerl':
					   ensure => installed,
             source    => 'c:\windowsRepo\windows\package_distro\strawberry-perl-5.20.1.1-32bit.msi',
          }
				}
				'x64' :
				{
					#notify { '7zaCopied' : message => '7za copied to Program Files (x86)', }
					exec
					{
						 'cmd /c copy /Y c:\windowsRepo\windows\package_distro\7za.exe "c:\Program Files (x86)\7-Zip\\"':
						path	=>	$::path,
						require	=>	Package['7zip'],
						#before	=>	Notify['7zaCopied'],
						creates => 'c:\Program Files (x86)\7-Zip\7za.exe',
					}
          package
          {
           'StrawberryPerl':
             ensure => installed,
             source    => 'c:\windowsRepo\windows\package_distro\strawberry-perl-5.20.1.1-64bit.msi',
          }
				}
			}
			#notify { 'apacheUnzipped' : message => 'apache unzipped into c:/web', }
      exec
      {
         'unzipApache':
            path => 'C:\WINDOWS\system32\;C:\Program Files\7-Zip\;C:\Program Files (x86)\7-Zip\\',
            command => '7za -o"c:\web" x c:\windowsRepo\windows\package_distro\httpd-2.4.9-x86.zip',
					  cwd	=> 'C:/web',
					  unless	=> 'cmd /c dir c:\web\Apache24\bin\httpd.exe',
					  logoutput => true,
					  require	=>	Package['7zip'],
       }

			file
			{
				'c:\web\Apache24\bin\httpd.exe':
				  ensure => file,
				  owner => 'Administrators',
					mode => 755,
					require	=> Exec['unzipApache'],
			}
			file
			{
				'c:\web\Apache24' :
          ensure => directory,
          owner => 'Administrators',
					mode => 777,
					require	=> Exec['unzipApache'],
			}
      file
      {
        'c:\web\Apache24\bin' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
			file
			{
				'c:\web\Apache24\conf' :
				  ensure => directory,
				  owner => 'Administrators',
					mode => 777,
					require	=> Exec['unzipApache'],
			}
      file
      {
        'c:\web\Apache24\conf\extra' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\conf\ssl' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
			file
			{
				'c:\web\Apache24\logs' :
          ensure => directory,
          owner => 'Administrators',
					mode => 777,
					require	=> Exec['unzipApache'],
			}
      file
      {
        'c:\web\Apache24\cgi-bin' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\error' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\htdocs' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\icons' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\include' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\lib' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\modules' :
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
          require => Exec['unzipApache'],
      }
      file
      {
        'c:\web\Apache24\content':
          ensure => directory,
          owner => 'Administrators',
          mode => 777,
      }



			file
			{
				'httpd.conf':
					ensure =>  file,
					path	=>	'c:/web/Apache24/conf/httpd.conf',
					mode	=>	444,
					owner	=>	'Administrator',
					source	=>	'puppet:///modules/servinfo/windows/httpd.conf',
			}

      #notify { 'attemptApacheInstall1' : message => 'attempting Apache install...', }
      file
      {
            'install_tracker':
                  ensure =>  file,
                  path	=>	'c:/web/Apache24/conf/installed',
                  mode	=>	444,
                  owner	=>	'Administrator',
                  content	=>	'Apache install run',
      }
      exec
      {
        'installApacheService':
          cwd => 'c:\web\Apache24\bin',
          path => ['c:\web','c:\web\Apache24\bin','c:\Windows\system32', $::path ],
          command => 'cmd /c c:\web\Apache24\bin\httpd.exe -k install -n "sitaservInfoApache" -f "c:\web\Apache24\conf\httpd.conf"',
          require => [ File['web_dir'], ],
          logoutput => true,
          unless => 'cmd /c c:\Windows\system32\sc.exe query sitaservInfoApache',
      }
      Exec['installApacheService']->File['install_tracker']
      #notify{ 'attemptApacheInstall2' : message => 'attempted Apache install', }
      #Notify['attemptApacheInstall1']->Exec['installApacheService']->Notify['attemptApacheInstall2']

      # vcredist - Visual C library distributions may need to be installed on 2008 R2
      if($::kernelmajversion == '6.1' or $::kernelmajversion == '5.2' )
      {
        #notify { 'vcredistInstall': message => 'attempting to install Visual C library distribution', }
	      file
	      {
	        'vcredist_x86.exe':
	                ensure => file,
	                path => 'c:\windowsRepo\windows\package_distro\vcredist_x86.exe',
	                owner => 'Everyone',
	                mode => 777,
	      }
	      package
	      {
	        'vcredist':
	        ensure    => 'installed',
	        install_options => ['/q', ],
	        source    => 'c:\windowsRepo\windows\package_distro\vcredist_x86.exe',
	        require =>  File['vcredist_x86.exe'],
	      }
	      Package['vcredist']->Exec['installApacheService']
      }

      #notify{'attemptSettingACL1': message => 'attempting to set Windows ACLs for Apache...', }
      exec
      {
        'setWindowsACLweb':
          cwd => 'c:\web',
          path => ['c:\WINDOWS\system32', '$::path'],
          command => 'cmd /c c:\WINDOWS\system32\cacls.exe c:\web /C /E /T /P Administrators:F Administrator:F Everyone:F',
          logoutput => true,
      }
      #notify{'attemptSettingACL2': message => 'attempted to set Windows ACLs for Apache', }
      #Notify['attemptSettingACL1']->Exec['setWindowsACLweb']->Notify['attemptSettingACL2']->Notify['attemptApacheInstall1']

      service { 'sitaservInfoApache':
        ensure => 'running',
        enable => true,
        require => File['httpd.conf'],
        }


      File['httpd.conf']->Exec['installApacheService']->Service['sitaservInfoApache']->File['install_tracker']
      File['httpd.conf']~>Service['sitaservInfoApache']




      file
      {
        'type.txt':
          ensure => file,
          path => 'c:\web\Apache24\content\type.txt',
          mode => 444,
          content => template('servinfo/type.txt.erb'),
      }
      # add in server information to server itself
      file
      {
        "${::fqdn}_contact.txt":
        ensure => file,
        path => 'c:\web\Apache24\content\contact.txt',
        mode => 644,
        owner =>  'Administrator',
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/contact.txt",
      }
      file
      {
        "${::fqdn}_notes.txt":
        ensure => file,
        path => 'c:\web\Apache24\content\notes.txt',
        mode => 644,
        owner =>  'Administrator',
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/notes.txt",
      }
      file
      {
        "${::fqdn}_prefix.txt":
        ensure => file,
        path => 'c:\web\Apache24\content\prefix.txt',
        mode => 644,
        owner =>  'Administrator',
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/prefix.txt",
      }
      file
      {
        "${::fqdn}_project.txt":
        ensure => file,
        path => 'c:\web\Apache24\content\project.txt',
        mode => 644,
        owner =>  'Administrator',
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/project.txt",
      }
      file
      {
        "${::fqdn}_usage.txt":
        ensure => file,
        path => 'c:\web\Apache24\content\usage.txt',
        mode => 644,
        owner =>  'Administrator',
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/usage.txt",
      }
      file
      {
        "${::fqdn}_os.pl":
          ensure => file,
          path => 'c:\web\Apache24\content\os.pl',
          mode => 755,
          owner => 'Administrator',
          content => template('servinfo/os.pl.erb'),
      }



		}










		'Solaris':
    {

      include servinfo::cswlighttpd

      #notify { 'servInfoSolMsg1' : message => 'this is a solaris server', }

      group
      {
        'servinfo_group':
          ensure => 'present',
          name => 'servinfo',
          gid => '1254',
          before => User['servinfo_user'],
      }
      user
      {
        'servinfo_user':
           ensure => 'present',
           name => 'servinfo',
           uid => '1254',
           gid => 'servinfo',
           home => '/var/servinfo',
           password => 'nMh0wxdZfcaFc',
           shell => '/bin/bash',
      }



      case $::virtual
      {
        'physical' :
        {
          file
          {
            'genVMList.ksh':
              ensure => file,
              path => '/var/servinfo/genVMList.ksh',
              mode => 555,
              owner => servinfo,
              group => servinfo,
              source => 'puppet:///modules/servinfo/getVMList/getVMList-solaris.ksh',
          }

          cron
          {
            'generateVMList':
              command => '/var/servinfo/genVMList.ksh',
              user => 'servinfo',
              minute => '*',
          }
        }
      }

      file
      {
        'servInfoDir':
          ensure => directory,
          path => '/var/servinfo/servInfo',
          owner => servinfo,
          group => servinfo,
          mode => 755,
      }

      file
      {
        'servInfoContentDir':
          ensure => directory,
          path => '/var/servinfo/servInfo/content',
          owner => servinfo,
          group => servinfo,
          mode => 755,
          require => User['servinfo_user'],
      }

      file
      {
        'type.txt':
          ensure => file,
          path => '/var/servinfo/servInfo/content/type.txt',
          owner => servinfo,
          group => servinfo,
          mode => 444,
          content => template('servinfo/type.txt.erb'),
          require => User['servinfo_user'],
      }

      file
      {
        'os.pl':
          ensure =>  file,
          path  =>  '/var/servinfo/servInfo/content/os.pl',
          mode  =>  555,
          owner =>  servinfo,
          group =>  servinfo,
          content => template('servinfo/os.pl.erb'),
          require => User['servinfo_user'],
      }

      file
      {
        'this.css':
          ensure =>  file,
          path  =>  '/var/servinfo/servInfo/content/this.css',
          mode  =>  444,
          owner =>  servinfo,
          group =>  servinfo,
          source  =>  'puppet:///modules/servinfo/this.css',
          require => User['servinfo_user'],
      }

      file
      {
        'collateVMInfo.pl':
        ensure  =>  file,
        path  =>  '/var/servinfo/collateVMInfo.pl',
        mode  =>  755,
        owner =>  servinfo,
        group =>  servinfo,
        source  =>  'puppet:///modules/servinfo/collateVMInfo.pl',
        require => User['servinfo_user'],
      }
      cron
      {
        'collateVMInfo':
          command => '/var/servinfo/collateVMInfo.pl',
          user => 'servinfo',
          minute => '*',
      }
      # add in server information to server itself
      file
      {
        "${::fqdn}_contact.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/contact.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/contact.txt",
      }
      file
      {
        "${::fqdn}_notes.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/notes.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/notes.txt",
      }
      file
      {
        "${::fqdn}_prefix.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/prefix.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/prefix.txt",
      }
      file
      {
        "${::fqdn}_project.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/project.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/project.txt",
      }
      file
      {
        "${::fqdn}_usage.txt":
        ensure => file,
        path => '/var/servinfo/servInfo/content/usage.txt',
        mode => 644,
        owner => servinfo,
        group => servinfo,
        source => "puppet:///modules/servinfo/system_details/${::fqdn}/usage.txt",
      }
    }

		default :
		{
			fail("Could not classify OS family ${::osfamily}")
		}

	}




}
