# Sonic Pi Rakefile
# Builds Sonic Pi for the current platform

RUBY_API = RbConfig::CONFIG['ruby_version']

OS = case RUBY_PLATFORM
when /.*arm.*-linux.*/
  :raspberry
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
SUPERCOLLIDER_VERSION = "3.9.1"
SC_PLUGINS_VERSION = "3.9.0" # 3.9.1 is currently in pre-release and I've had issues installing it, but 3.9.0 seems to work fine.
AUBIO_VERSION = "c6ae035" # v0.4.6
OSMID_VERSION = "391f35f789f18126003d2edf32902eb714726802"
RUGGED_VERSION = "0.26.0"

pkg_manager = :invalid

text_cyan = '\033[1;36m'
text_nc = '\033[0m'

task build: %w[install_dependency_packages compile_extensions build_documentation build_qt_docs]

task :install_dependency_packages do
  case OS
  when :raspberry
    # Use apt to install the packages
    pkg_manager = :apt
    print_coloured_text("Installing dependencies for building supercollider, as well as qt5 and supporting libraries for gui...")

    dep_packages = []
    dep_packages.push("g++")
    dep_packages.push("ruby")
    dep_packages.push("ruby-dev")
    dep_packages.push("pkg-config")
    dep_packages.push("git")
    dep_packages.push("libjack-jackd2-dev")
    dep_packages.push("libsndfile1-dev")
    dep_packages.push("libasound2-dev")
    dep_packages.push("libavahi-client-dev")
    dep_packages.push("libicu-dev")
    dep_packages.push("libreadline6-dev")
    dep_packages.push("libfftw3-dev")
    dep_packages.push("libxt-dev")
    dep_packages.push("libudev-dev")
    dep_packages.push("libxt-dev")
    dep_packages.push("cmake")
    dep_packages.push("libboost-dev")
    dep_packages.push("libqwt-qt5-dev")

    cmd = `sudo apt-get install -y \
         g++ ruby ruby-dev pkg-config git build-essential libjack-jackd2-dev \
         libsndfile1-dev libasound2-dev libavahi-client-dev libicu-dev \
         libreadline6-dev libfftw3-dev libxt-dev libudev-dev cmake libboost-dev \
         libqwt-qt5-dev libqt5scintilla2-dev libqt5svg5-dev qt5-qmake qt5-default \
         qttools5-dev qttools5-dev-tools qtdeclarative5-dev libqt5webkit5-dev \
         qtpositioning5-dev libqt5sensors5-dev qtmultimedia5-dev libffi-dev \
         curl python erlang-base`
  when :linux
    # Ask which package manager to use
    while (pkg_manager == :invalid) do
      puts("Which package manager should we use to install dependency packages?")
      puts("1: apt")

      pkg_manager = case gets.chomp
      when "1"
        :apt
      else
        :invalid
      end
    end

    # Ask if the user wants to use checkinstall
    checkinstall = :invalid
    distroType = :none
    while (checkinstall == :invalid) do
      puts("Do you want to use checkinstall to install programs made from source? (Available on Debian, Ubuntu and some other distros)")
      puts("This makes it easier to uninstall these programs.")
      puts("(yes/no)")

      checkinstall = case gets.chomp
      when "y" || "yes"
        :yes
      when "n" || "no"
        :no
      else
        :invalid
      end
    end

    if (checkinstall == :yes)

    end

    # Install dependency packages
    print_coloured_text("Installing dependencies for building supercollider, as well as qt5 and supporting libraries for gui...")
    case pkg_manager
    when :apt

      if (sc_ver )
      cmd = `sudo apt-get install -y \
           g++ ruby ruby-dev pkg-config git build-essential libjack-jackd2-dev \
           libsndfile1-dev libasound2-dev libavahi-client-dev libicu-dev \
           libreadline6-dev libfftw3-dev libxt-dev libudev-dev cmake libboost-dev \
           libqwt-qt5-dev libqt5scintilla2-dev libqt5svg5-dev qt5-qmake qt5-default \
           qttools5-dev qttools5-dev-tools qtdeclarative5-dev libqt5webkit5-dev \
           qtpositioning5-dev libqt5sensors5-dev qtmultimedia5-dev libffi-dev \
           curl python erlang-base`
    else

    end
  when :macos

  when :windows

  else

  end
end

task :build_supercollider do
  case OS
  when :raspberry
    # Use apt
  when :linux
    print_coloured_text("Building supercollider and sc3-plugins from source...")
    case pkg_manager
    when :apt
      # Build SuperCollider
      `git clone --recursive https://github.com/supercollider/supercollider.git || true`
      `cd supercollider`
      `git checkout Version-#{SUPERCOLLIDER_VERSION}`
      `git submodule init && git submodule update`
      `git submodule update --init`
      `mkdir -p build`
      `cd build`
      `cmake -DSC_EL=no ..`
      `make`
      `cd ../..` # build folder
      # Install SuperCollider
      print_coloured_text("Installing SuperCollider...")
      if (checkinstall == :yes)
        `cd supercollider`
        `sudo checkinstall --pkgname=supercollider --pkgversion=1:#{SUPERCOLLIDER_VERSION} --pkglicense=GPL-2.0 --pkggroup=sound --nodoc --default --install=no`
        `sudo dpkg -i supercollider_#{SUPERCOLLIDER_VERSION}-1_amd64.deb`
        `cd ..` # build folder
      else
        `cd supercollider`
        `make install`
        `cd ..` # build folder
      end

      # Build sc3-plugins
      `git clone --recursive https://github.com/supercollider/sc3-plugins.git || true`
      `cd sc3-plugins`
      `git checkout Version-#{SC_PLUGINS_VERSION}`
      `git submodule init && git submodule update`
      `git submodule update --init`
      `cp -r external_libraries/nova-simd/* source/VBAPUGens`
      `mkdir -p build`
      `cd build`
      #cmake -DSC_PATH=../../supercollider -DCMAKE_INSTALL_PREFIX=/usr/local ..
      #cmake -DCMAKE_INSTALL_PREFIX=/usr/local --build . --config Release
      `cmake -DSC_PATH=../../supercollider ..`
      `cmake --build . --config Release`
      `make`
      `cd ../..` # build folder

      # Install sc3-plugins
      print_coloured_text("Installing sc3-plugins...")
      if (checkinstall == :yes)
        `cd sc3-plugins`
        `sudo checkinstall --pkgname=sc3-plugins --pkgversion=1:#{SC_PLUGINS_VERSION} --pkglicense=GPL-2.0 --pkggroup=sound --nodoc --default --install=no`
        `sudo dpkg -i sc3-plugins_#{SC_PLUGINS_VERSION}-1_amd64.deb`
        `cd ..` # build folder
      else
        `cd sc3-plugins`
        `make install`
        `cd ..` # build folder
      end
    else

    end
  when :macos

  when :windows

  else

  end
end

task :compile_extensions do
  ruby "app/server/ruby/bin/compile-extensions.rb"
end

task :build_documentation do
  ruby "app/server/ruby/bin/i18n-tool.rb -t"
end

task :build_qt_docs do
  `cp -f app/gui/qt/ruby_help.tmpl app/qui/qt/ruby_help.h`
  ruby "app/server/ruby/bin/qt-doc.rb -o app/qui/qt/ruby_help.h"
end



def :check_ver |package| do
  ver = get_ver(package.split(" ")[0])
  spec_ver = package.split(" ")[2]

  ver_major = ver.split(".")[0].to_i
  ver_minor = ver.split(".")[1].to_i
  ver_patch = ver.split(".")[2].to_i

  spec_ver_major = spec_ver.split(".")[0].to_i
  spec_ver_minor = spec_ver.split(".")[1].to_i
  spec_ver_patch = spec_ver.split(".")[2].to_i

  if (ver_major >= spec_ver_major)
    if (ver_minor >= spec_ver_minor)
      if (ver_patch >= spec_ver_patch)
        return true
      end
    end
  end
  
  return false
end

def :get_ver |package| do
  case pkg_manager
  when :apt
    ver = `apt-cache show #{package}| grep '^Version:`
    ver.slice!("Version: ")
    ver = ver.split("+")[0]
    ver = ver.split("~")[0]
    return ver
  else
  end
end

def :print_coloured_text |text| do
  `echo -e "#{text_cyan}#{text}#{text_nc}"`
end
