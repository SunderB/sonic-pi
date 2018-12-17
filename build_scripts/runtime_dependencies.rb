require_relative 'utils'

# Application/library versions built by this script.
MIN_SUPERCOLLIDER_VERSION = "3.9"
SUPERCOLLIDER_VERSION = "3.9.1"

MIN_SC_PLUGINS_VERSION = "3.9.0"
SC_PLUGINS_VERSION = "3.9.0" # 3.9.1 is currently in pre-release and I've had issues installing it, but 3.9.0 seems to work fine.

AUBIO_VERSION = "c6ae035" # v0.4.6
OSMID_VERSION = "391f35f789f18126003d2edf32902eb714726802"

# External runtime dependencies: supercollider & sc3_plugins, aubio
task :supercollider, [:make_jobs, :sonic_pi_root] do |t, args|
	args.with_defaults(:make_jobs => 1)
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  
  #OS = ask_if_raspbian if (OS == :linux_arm)
  info("Checking the version of supercollider installed...")
  case OS
  when :linux || :raspberry
    if (check_ver("supercollider >= #{MIN_SUPERCOLLIDER_VERSION}", SPI_BUILD_CONFIG.pkg_manager) == false)
      build_supercollider
    elsif (check_ver("sc3-plugins >= #{MIN_SC_PLUGINS_VERSION}", SPI_BUILD_CONFIG.pkg_manager) == false)
      build_supercollider
    else
      check = exec_bash(%Q(dpkg -S `which scsynth`))
      if (check.include?("supercollider") == false)
        # Supercollider isn't installed
        info("The version of supercollider avaiable is good, installing supercollider...")
        install_packages(["supercollider"], SPI_BUILD_CONFIG.pkg_manager)
      else
        # Supercollider is installed
        info("The version of supercollider installed is good! :)")
      end
    end
  when :windows
		build_supercollider
  when :macos
		build_supercollider
  end
end

desc "Build Supercollider from source"
task :build_supercollider, [:make_jobs, :sonic_pi_root] do |t, args|
	args.with_defaults(:make_jobs => 1)
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
    install_packages(Dependencies::Raspberry.supercollider, SPI_BUILD_CONFIG.pkg_manager)
  when :linux
    install_packages(Dependencies::Linux.supercollider, SPI_BUILD_CONFIG.pkg_manager)
    info("Building supercollider and sc3-plugins from source...")

    # Build SuperCollider
    exec_commands([
      %Q(cd build),
      %Q(git clone --recursive https://github.com/supercollider/supercollider.git || true),
      %Q(cd supercollider),
      %Q(git checkout Version-#{SUPERCOLLIDER_VERSION}),
      %Q(git submodule init && git submodule update),
      %Q(git submodule update --init),
      %Q(mkdir -p build),
      %Q(cd build),
      %Q(cmake -DSC_EL=no ..),
      %Q(make -j#{args.make_jobs}),
      %Q(cd ../..) # build folder
    ])

    # Install SuperCollider
    info("Installing SuperCollider...")

    if (SPI_BUILD_CONFIG.checkinstall == :yes)
      case SPI_BUILD_CONFIG.distro
      when :debian
        exec_commands([
          %Q(cd build/supercollider/build),
          %Q(sudo checkinstall --pkgname=supercollider --pkgversion=1:#{SUPERCOLLIDER_VERSION} --pkglicense=GPL-2.0 --pkggroup=sound --nodoc --default --install=no),
          %Q(sudo dpkg -i supercollider_#{SUPERCOLLIDER_VERSION}-1_amd64.deb),
          %Q(cd ../..) # build folder
        ])
      when :rpm
        exec_commands([
          %Q(cd build/supercollider/build),
          %Q(sudo checkinstall --pkgname=supercollider --pkgversion=1:#{SUPERCOLLIDER_VERSION} --pkglicense=GPL-2.0 --pkggroup=sound --nodoc --default --install=no),
          %Q(sudo dpkg -i supercollider_#{SUPERCOLLIDER_VERSION}-1_amd64.rpm),
          %Q(cd ../..) # build folder
        ])
      else
      end
    else
      exec_commands([
        %Q(cd build/supercollider/build),
        %Q(make install),
        %Q(cd ../..) # build folder
      ])
    end

    # Build sc3-plugins
    exec_commands([
      %Q(cd build),
      %Q(git clone --recursive https://github.com/supercollider/sc3-plugins.git || true),
      %Q(cd sc3-plugins),
      %Q(git checkout Version-#{SC_PLUGINS_VERSION}),
      %Q(git submodule init && git submodule update),
      %Q(git submodule update --init),
      %Q(cp -r external_libraries/nova-simd/* source/VBAPUGens),
      %Q(mkdir -p build),
      %Q(cd build),
      #cmake -DSC_PATH=../../supercollider -DCMAKE_INSTALL_PREFIX=/usr/local ..
      #cmake -DCMAKE_INSTALL_PREFIX=/usr/local --build . --config Release
      %Q(cmake -DSC_PATH=../../supercollider ..),
      %Q(cmake --build . --config Release),
      %Q(make -j#{args.make_jobs}),
      %Q(cd ../..) # build folder
    ])

    # Install sc3-plugins
    info("Installing sc3-plugins...")
    if (SPI_BUILD_CONFIG.checkinstall == :yes)
      case SPI_BUILD_CONFIG.distro
      when :debian
        exec_commands([
          %Q(cd build/sc3-plugins/build),
          %Q(sudo checkinstall --pkgname=sc3-plugins --pkgversion=1:#{SC_PLUGINS_VERSION} --pkglicense=GPL-2.0 --pkggroup=sound --nodoc --default --install=no),
          %Q(sudo dpkg -i supercollider_#{SC_PLUGINS_VERSION}-1_amd64.deb),
          %Q(cd ../..) # build folder
        ])
      when :rpm
        exec_commands([
          %Q(cd build/sc3-plugins/build),
          %Q(sudo checkinstall --pkgname=sc3-plugins --pkgversion=1:#{SC_PLUGINS_VERSION} --pkglicense=GPL-2.0 --pkggroup=sound --nodoc --default --install=no),
          %Q(sudo dpkg -i supercollider_#{SC_PLUGINS_VERSION}-1_amd64.rpm),
          %Q(cd ../..) # build folder
        ])
      else
      end
    else
      exec_commands([
        %Q(cd build/supercollider/build),
        %Q(make install),
        %Q(cd ../..) # build folder
      ])
    end
  when :macos
		# Portable build - Package with Sonic Pi
  when :windows
		# Portable build - Package with Sonic Pi
		exec_win_commands([
			%Q(cd build)
			%Q(git clone https://github.com/supercollider/supercollider.git)
			%Q(cd supercollider)
			#git submodule init && git submodule update
			%Q(mkdir build)
			%Q(cd build)
			%Q(cmake -G "Visual Studio 12 2013" ..)
			%Q(cmake --build . --config Release)

			%Q(xcopy /E ".\\server\\scsynth\\Release\\*" "..\\..\\sonic-pi\\app\\server\\native\\windows")
		])
  end
end

desc "Build Aubio from source"
task :build_aubio, [:make_jobs, :sonic_pi_root] do |t, args|
	args.with_defaults(:make_jobs => 1)
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
  when :linux
    info("Building libaubio from source...")
    install_packages(Dependencies::Linux.aubio, SPI_BUILD_CONFIG.pkg_manager)
    exec_commands([
      %Q(cd build),
      %Q(git clone https://git.aubio.org/git/aubio/ || true),
      %Q(cd aubio),
      %Q(git checkout #{AUBIO_VERSION}),
      %Q(make getwaf),
      %Q(./waf configure),
      %Q(./waf build),
      %Q(sudo ./waf install),
      %Q(cd ..) # Build folder
    ])
  when :windows
  when :macos
  end
end

# Internal runtime dependencies: osmid
# Should be built with Sonic Pi
desc "Build osmid from source"
task :build_osmid, [:make_jobs, :sonic_pi_root] do |t, args|
	args.with_defaults(:make_jobs => 1)
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))

  OS = ask_if_raspbian if (OS == :linux_arm)
  
  case OS
  when :raspberry
  when :linux
    install_packages(Dependencies::Linux.osmid, SPI_BUILD_CONFIG.pkg_manager)
    info("Building osmid from source...")
    exec_commands([
      %Q(cd build),
      %Q(git clone https://github.com/llloret/osmid.git || true),
      %Q(cd osmid),
      %Q(git checkout ${OSMID_VERSION}),
      %Q(mkdir -p build),
      %Q(cd build),
      %Q(cmake ..),
      %Q(make -j#{args.make_jobs})
    ])
    info("Installing osmid...")
    exec_commands([
      %Q(cd build/osmid/build), # Return to where we were before
      %Q(mkdir -p #{args.sonic_pi_root}/app/server/native/linux/osmid),
      %Q(install m2o o2m -t #{args.sonic_pi_root}/app/server/native/linux/osmid),
      %Q(cd ../..) # Build folder
    ])
  when :windows
  when :macos
  end
end
