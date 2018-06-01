# Sonic Pi Rakefile
# Builds Sonic Pi for the current platform

require 'fileutils'
require "./Dependencies"

RUBY_API = RbConfig::CONFIG['ruby_version']

OS = case RUBY_PLATFORM
when /.*arm.*-linux.*/
  :linux_arm
when /.*linux.*/
  :linux
when /.*darwin.*/
  :macos
when /.*mingw.*|.*mswin.*|.*bccwin.*|.*wince.*|.*emx.*/
  :windows
else
  RUBY_PLATFORM
end

# Application/library versions built by this script.
MIN_SUPERCOLLIDER_VERSION = "3.9"
SUPERCOLLIDER_VERSION = "3.9.1"

MIN_SC_PLUGINS_VERSION = "3.9.0"
SC_PLUGINS_VERSION = "3.9.0" # 3.9.1 is currently in pre-release and I've had issues installing it, but 3.9.0 seems to work fine.

AUBIO_VERSION = "c6ae035" # v0.4.6
OSMID_VERSION = "391f35f789f18126003d2edf32902eb714726802"
RUGGED_VERSION = "0.26.0"

_SONIC_PI_ROOT = File.join(File.expand_path(Dir.pwd),"build","sonic-pi")

pkg_manager = :invalid
checkinstall = :invalid
distroType = :none

all_dependencies_installed = false

# task build: %w[install_all_dependency_packages supercollider build_aubio build_osmid build_erlang_files compile_extensions build_documentation build_qt_docs build_gui]
task :default => ["build"]

desc "Build Sonic Pi (default task)"
task :build, [:sonic_pi_root] => [
  "install_all_dependency_packages",
  "supercollider",
  "build_aubio",
  "copy_server_files",
  "copy_gui_files",
  "copy_bin_folder",
  "copy_etc_folder",
  "build_osmid",
  "build_erlang_files",
  "compile_extensions",
  "build_documentation",
  "build_qt_docs",
  "build_gui"
] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
end

desc "Install all dependency packages for building Sonic Pi"
task :install_all_dependency_packages do
  OS = ask_if_raspbian if (OS == :linux_arm)
  case OS
  when :raspberry
    # Use apt to install the packages
    pkg_manager = :apt
    print_coloured_text("Installing dependencies for building supercollider, as well as qt5 and supporting libraries for gui...")
    dependencies = Dependencies::Raspberry.supercollider
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Raspberry.aubio
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Raspberry.osmid
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Raspberry.server
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Raspberry.gui
    install_packages(dependencies, pkg_manager)
  when :linux
    pkg_manager = ask_pkg_manager
    checkinstall = ask_checkinstall
    distro = ask_distro if (checkinstall == :yes)

    # Install dependency packages
    print_coloured_text("Installing dependencies for building supercollider, as well as qt5 and supporting libraries for gui...")
    dependencies = Dependencies::Linux.supercollider
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Linux.aubio
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Linux.osmid
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Linux.server
    install_packages(dependencies, pkg_manager)
    dependencies = Dependencies::Linux.gui
    install_packages(dependencies, pkg_manager)
  when :macos

  when :windows

  else

  end
  all_dependencies_installed = true
end

task :supercollider do
  OS = ask_if_raspbian if (OS == :linux_arm)
  print_coloured_text("Checking the version of supercollider installed...")
  case OS
  when :raspberry
  when :linux
    if (check_ver("supercollider >= #{MIN_SUPERCOLLIDER_VERSION}", pkg_manager) == false)
      build_supercollider
    elsif (check_ver("sc3-plugins >= #{MIN_SC_PLUGINS_VERSION}", pkg_manager) == false)
      build_supercollider
    else
      check = exec_bash(%Q(dpkg -S `which scsynth`))
      if (check.include?("supercollider") == false)
        # Supercollider isn't installed
        print_coloured_text("The version of supercollider avaiable is good, installing supercollider...")
        install_packages(["supercollider"], pkg_manager)
      else
        # Supercollider is installed
        print_coloured_text("The version of supercollider installed is good! :)")
      end
    end
  when :windows

  when :macos

  end
end

desc "Build Supercollider from source"
task :build_supercollider do
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
    install_packages(Dependencies::Raspberry.supercollider, pkg_manager) if (all_dependencies_installed == false)
  when :linux
    install_packages(Dependencies::Linux.supercollider, pkg_manager) if (all_dependencies_installed == false)
    print_coloured_text("Building supercollider and sc3-plugins from source...")

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
      %Q(make),
      %Q(cd ../..) # build folder
    ])

    # Install SuperCollider
    print_coloured_text("Installing SuperCollider...")

    if (checkinstall == :yes)
      case distro
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
      %Q(make),
      %Q(cd ../..) # build folder
    ])

    # Install sc3-plugins
    print_coloured_text("Installing sc3-plugins...")
    if (checkinstall == :yes)
      case distro
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

  when :windows

  else

  end
end

desc "Build Aubio from source"
task :build_aubio do
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
  when :linux
    print_coloured_text("Building libaubio from source...")
    install_packages(Dependencies::Linux.aubio, pkg_manager) if (all_dependencies_installed == false)
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

desc "Copy Sonic Pi server files to build folder"
task :copy_server_files do
  print_coloured_text("Copying Sonic Pi server files to build folder...")
  FileUtils.cp('CHANGELOG.md', File.join('build','sonic-pi'))
  FileUtils.cp('COMMUNITY.md', File.join('build','sonic-pi'))
  FileUtils.cp('CONTRIBUTORS.md', File.join('build','sonic-pi'))
  FileUtils.cp('CORETEAM.html', File.join('build','sonic-pi'))
  FileUtils.cp('LICENSE.md', File.join('build','sonic-pi'))
  replace_dir(File.join('app','server'), File.join('build','sonic-pi','app','server'))
end

desc "Copy Sonic Pi QT GUI files to build folder"
task :copy_gui_files do
  print_coloured_text("Copying Sonic Pi QT GUI files to build folder...")
  replace_dir(File.join('app','gui','qt'), File.join('build','sonic-pi','app','gui','qt'))
  #replace_dir(File.join('..','app','gui','html'), File.join('sonic-pi','app','gui','html')) # Not currently functional
end

desc "Copy Sonic Pi '/bin' folder to build folder"
task :copy_bin_folder do
  print_coloured_text("Copying Sonic Pi '/bin' folder to build folder...")
  replace_dir(File.join('bin'), File.join('build','sonic-pi','bin'))
end

desc "Copy Sonic Pi '/etc' folder to build folder"
task :copy_etc_folder do
  print_coloured_text("Copying Sonic Pi '/etc' folder to build folder...")
  replace_dir(File.join('etc','buffers'), File.join('build','sonic-pi','etc','buffers'))
  replace_dir(File.join('etc','doc'), File.join('build','sonic-pi','etc','doc')) # Only needed at build time
  replace_dir(File.join('etc','examples'), File.join('build','sonic-pi','etc','examples')) # Only needed at build time
  replace_dir(File.join('etc','samples'), File.join('build','sonic-pi','etc','samples'))
  replace_dir(File.join('etc','synthdefs'), File.join('build','sonic-pi','etc','synthdefs'))
  #replace_dir(File.join('..','etc','snippets'), File.join('sonic-pi','etc','snippets')) # Not currently used
  #replace_dir(File.join('..','etc','wavetables'), File.join('sonic-pi','etc','wavetables')) # Not currently used
end

desc "Build osmid from source"
task :build_osmid, [:sonic_pi_root] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))

  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
  when :linux
    install_packages(Dependencies::Linux.osmid, pkg_manager) if (all_dependencies_installed == false)
    print_coloured_text("Building osmid from source...")
    exec_commands([
      %Q(cd build),
      %Q(git clone https://github.com/llloret/osmid.git || true),
      %Q(cd osmid),
      %Q(git checkout ${OSMID_VERSION}),
      %Q(mkdir -p build),
      %Q(cd build),
      %Q(cmake ..),
      %Q(make)
    ])
    print_coloured_text("Installing osmid...")
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

desc "Build Sonic Pi Erlang files"
task :build_erlang_files, [:sonic_pi_root] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
  when :linux
    install_packages(["erlang"], pkg_manager) if (all_dependencies_installed == false)
    print_coloured_text("Building Erlang files...")
    #exec_bash(%Q(cd "app/server/erlang"))
    # The current implementation of osc.erl uses Erlang features that require
    # at least Erlang 19.1 to be installed. 16.04 LTS is currently at 18.3.
    # If versions < 19.1 are installed, and we use the current code, the MIDI
    # implementation breaks because the Erlang OSC router is failing.
    ERLANG_VERSION = exec_bash(%Q(#{args.sonic_pi_root}/app/server/erlang/print_erlang_version))
    if (File.exist?(File.join(args.sonic_pi_root,"app","server","erlang","osc.erl.orig")))
      # Handle, if the original file in the source tree ever gets updated.
      exec_commands([
        %Q(cd #{args.sonic_pi_root}/app/server/erlang/),
        %Q(rm osc.erl.orig),
        %Q(git checkout osc.erl)
      ])
    end
    if (compare_versions(ERLANG_VERSION, "<=", "19.0"))
      exec_commands([
        %Q(cd #{args.sonic_pi_root}/app/server/erlang/),
        %Q(echo "Found Erlang version < 19.1 (${ERLANG_VERSION})! Updating source code."),
        %Q(sed -i.orig 's|erlang:system_time(nanosecond)|erlang:system_time(nano_seconds)|' osc.erl)
      ])
    end
    exec_commands([
      %Q(cd #{args.sonic_pi_root}/app/server/erlang/),
      %Q(erlc osc.erl),
      %Q(erlc pi_server.erl),
      %Q(cd ../../../..) # Build folder
    ])
  when :windows
  when :macos
  end
end

desc "Compile Sonic Pi ruby server extensions"
task :compile_extensions, [:sonic_pi_root] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  print_coloured_text("Compiling Sonic Pi server extensions...")
  ruby File.join(args.sonic_pi_root,'app','server','ruby','bin','compile-extensions.rb')
end

desc "Build Sonic Pi documention"
task :build_documentation, [:sonic_pi_root] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  print_coloured_text("Building documentation and applying translations...")
  ruby File.join(args.sonic_pi_root,'app','server','ruby','bin','i18n-tool.rb') + " -t"
end

desc "Build Sonic Pi QT docs"
task :build_qt_docs, [:sonic_pi_root] do |t, args|
  print_coloured_text("Building Sonic Pi QT docs...")
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  exec_bash(%Q(cp -f #{args.sonic_pi_root}/app/gui/qt/ruby_help.tmpl #{args.sonic_pi_root}/app/gui/qt/ruby_help.h))
  ruby File.join(args.sonic_pi_root,'app','server','ruby','bin','qt-doc.rb') + ' -o ' + File.join(args.sonic_pi_root,'app','gui','qt','ruby_help.h')
end

desc "Build Sonic Pi QT GUI"
task :build_gui, [:sonic_pi_root] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
  when :linux
    install_packages(Dependencies::Linux.gui, pkg_manager) if (all_dependencies_installed == false)
    print_coloured_text("Building QT GUI...")
    exec_commands([
      %Q(cd #{args.sonic_pi_root}/app/gui/qt),
      %Q(lrelease SonicPi.pro),
      %Q(qmake -qt=qt5 SonicPi.pro),
      %Q(make)
    ])
  when :windows
  when :macos
  end
end

desc "Clean build folder"
task :clean_build_folder do
  print_coloured_text("Cleaning build folder...")
  FileUtils.remove_dir(File.join('build','sonic-pi','etc','docs'))
  FileUtils.remove_dir(File.join('build','sonic-pi','etc','examples'))
end



def ask_if_raspbian
  i = :invalid
  # Ask which package manager to use
  while (i == :invalid) do
    puts("Are you using Raspbian on a Raspberry Pi or other ARM device? (yes/no)")
    i = case STDIN.gets.chomp
    when "y" || "yes"
      :raspberry
    when "n" || "no"
      :linux
    else
      :invalid
    end
  end
  return i
end

def ask_pkg_manager
  m = :invalid
  # Ask which package manager to use
  while (m == :invalid) do
    puts("Which package manager should we use to install dependency packages?")
    puts("1: apt")

    m = case STDIN.gets.chomp
    when "1"
      :apt
    else
      :invalid
    end
  end
  return m
end

def ask_checkinstall
  # Ask if the user wants to use checkinstall
  c = :invalid
  while (c == :invalid) do
    puts("Do you want to use checkinstall to install programs made from source? (Available on Debian, Ubuntu and some other distros)")
    puts("This makes it easier to uninstall these programs.")
    puts("(yes/no)")

    c = case STDIN.gets.chomp
    when "y" || "yes"
      :yes
    when "n" || "no"
      :no
    else
      :invalid
    end
  end
  return c
end

def ask_distro
  d = :none
  while (d == :none) do
    puts("What package type do you want to install, and how do you want to install it?")
    puts("1 - for Debian, Ubuntu and other Debian based distros - .deb packages installed via. dpkg")
    puts("2 - for RedHat and other distros - .rpm package")

    d = case STDIN.gets.chomp
    when "1"
      :debian
    when "2"
      :rpm
    else
      :none
    end
  end
  return d
end

def install_packages(packages, _pkg_manager)
  puts packages
  package_names = []
  length = packages.length - 1
  for i in 0..length
    package_names.push(packages[i].split(" ")[0])
  end

  case _pkg_manager
  when :apt
    cmd = exec_bash(%Q(sudo apt-get install -y #{package_names.join(" ")}))
  else
  end
end

def check_ver(pkg_spec_ver, _pkg_manager)
  # Get the version available and the version specified in the dependencies
  ver = get_ver(pkg_spec_ver.split(" ")[0], _pkg_manager)
  op = pkg_spec_ver.split(" ")[1]
  spec_ver = pkg_spec_ver.split(" ")[2]

  if (spec_ver != nil)
    return compare_versions(ver, op, spec_ver)
  else
    # No version is specified in the dependencies
    return true
  end
end

def compare_versions(ver, op, spec_ver)
  version1 = ver.split(".")
  version2 = spec_ver.split(".")

  # Compare the versions
  for i in 0..2
    version1.push("0") if (version1[i] == nil)
    version2.push("0") if (version2[i] == nil)
    case op
    when ">="
      if ((version1[i].to_i >= version2[i].to_i) == false)
        # The version is less than the version specified in the dependencies!
        return false
      end
    when "=" || "=="
      if ((version1[i].to_i == version2[i].to_i) == false)
        # The version is less than the version specified in the dependencies!
        return false
      end
    when "<="
      if ((version1[i].to_i <= version2[i].to_i) == false)
        # The version is less than the version specified in the dependencies!
        return false
      end
    else
      return false
    end
  end
  return true
end

def get_ver(package, _pkg_manager)
  case _pkg_manager
  when :apt
    ver = exec_bash(%Q(apt-cache show #{package}| grep '^Version:'))
    ver = ver.split("\n")[0] # Get the first line of the output
    ver = ver.to_s
    ver.slice!("Version: ") # Remove the 'Version: ' bit
    ver = ver.split("+")[0]
    ver = ver.split("-")[0]
    ver = ver.split("~")[0]
    ver = ver.split(":")[1]
    puts(ver)
    return ver
  else
  end
end

def print_coloured_text(text)
  text_cyan = '\033[1;36m'
  text_nc = '\033[0m'
  exec_bash(%Q(echo \\"#{text_cyan}#{text}#{text_nc}\\"))
end

def exec_commands(commands)
  exec_bash(commands.join(" && "))
end

def exec_bash(command)
  #puts('bash -licv' + command)
  #result = `bash -licv "#{command}"`

  puts("Executing command: " + command) # for debugging
  result = `sh -c "#{command}"`
  puts(result.to_s)
  return result
end

def replace_dir(dir1, dir2)
  puts(File.expand_path(dir1))
  puts(File.expand_path(dir2))
  FileUtils.rm_rf(dir2)
  FileUtils.copy_entry(dir1, dir2, remove_destination=true)
end

def create_dir(path)
  FileUtils.mkdir_p(path) if (File.directory?(path) == false)
end
