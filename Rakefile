# Sonic Pi Rakefile
# Builds Sonic Pi for the current platform

require 'fileutils'
require "./build_scripts/utils"
require "./build_scripts/runtime_dependencies"
require "./build_scripts/Dependencies"

RUBY_API = RbConfig::CONFIG['ruby_version']

# Application/library versions built by this script.
RUGGED_VERSION = "0.26.0"

all_dependencies_installed = false

# task build: %w[install_all_dependency_packages supercollider build_aubio build_osmid build_erlang_files compile_extensions build_documentation build_qt_docs build_gui]
task :default => ["build"]

desc "Build Sonic Pi (default task)"
task :build, [:make_jobs, :sonic_pi_root] => [
	"configure",
  "install_all_dependency_packages",
  "make_build_folder",
  "copy_server_files",
  
  "supercollider",
  "build_aubio",
  
  "copy_gui_files",
  "copy_bin_folder",
  "copy_etc_folder",
  
  "build_osmid",
  
  "build_erlang_files",
  "compile_extensions",
  "build_documentation",
  "build_qt_docs",
  
  "build_gui",
  
  "clean_build_folder"
] do |t, args|
	args.with_defaults(:make_jobs => 1)
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
end

task :configure do
	OS = ask_if_raspbian if (OS == :linux_arm)
	if (OS == :linux)
		SPI_BUILD_CONFIG.pkg_manager = ask_pkg_manager
    checkinstall = ask_checkinstall
    distro = ask_distro if (checkinstall == :yes)
  elsif (OS == :raspberry)
  	SPI_BUILD_CONFIG.pkg_manager = :apt
	end
end


desc "Install all dependency packages for building Sonic Pi"
task :install_all_dependency_packages do
  
  case OS
  when :raspberry
    # Use apt to install the packages
    SPI_BUILD_CONFIG.pkg_manager = :apt
    info("Installing dependencies for building supercollider, as well as qt5 and supporting libraries for gui...")
    #dependencies = Dependencies::Raspberry.supercollider
    #install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
    #dependencies = Dependencies::Raspberry.aubio
    #install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
		
    dependencies = Dependencies::Raspberry.server
    install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
    dependencies = Dependencies::Raspberry.gui
    install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
  when :linux

    # Install dependency packages
    info("Installing dependencies for building supercollider, as well as qt5 and supporting libraries for gui...")
    #dependencies = Dependencies::Linux.supercollider
    #install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
    #dependencies = Dependencies::Linux.aubio
    #install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
    #dependencies = Dependencies::Linux.osmid
    #install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
    
    dependencies = Dependencies::Linux.server
    install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
    dependencies = Dependencies::Linux.gui
    install_packages(dependencies, SPI_BUILD_CONFIG.pkg_manager)
  when :macos

  when :windows

  else

  end
  all_dependencies_installed = true
end

task :make_build_folder do
  sonic_pi_build_folder = File.join(File.expand_path(Dir.pwd), "build", "sonic-pi")
  FileUtils.rm_rf(sonic_pi_build_folder)
  create_dir(sonic_pi_build_folder)
end

# Build and/or install Supercollider

# Build Aubio

desc "Copy Sonic Pi server files to build folder"
task :copy_server_files do
  info("Copying Sonic Pi server files to build folder...")
  FileUtils.cp('CHANGELOG.md', File.join('build','sonic-pi'))
  FileUtils.cp('COMMUNITY.md', File.join('build','sonic-pi'))
  FileUtils.cp('CONTRIBUTORS.md', File.join('build','sonic-pi'))
  FileUtils.cp('CORETEAM.html', File.join('build','sonic-pi'))
  FileUtils.cp('LICENSE.md', File.join('build','sonic-pi'))
  replace_dir(File.join('app','server'), File.join('build','sonic-pi','app','server'))
end

desc "Copy Sonic Pi QT GUI files to build folder"
task :copy_gui_files do
  info("Copying Sonic Pi QT GUI files to build folder...")
  replace_dir(File.join('app','gui','qt'), File.join('build','sonic-pi','app','gui','qt'))
  #replace_dir(File.join('..','app','gui','html'), File.join('sonic-pi','app','gui','html')) # Not currently functional
end

desc "Copy Sonic Pi '/bin' folder to build folder"
task :copy_bin_folder do
  info("Copying Sonic Pi '/bin' folder to build folder...")
  replace_dir(File.join('bin'), File.join('build','sonic-pi','bin'))
end

desc "Copy Sonic Pi '/etc' folder to build folder"
task :copy_etc_folder do
  info("Copying Sonic Pi '/etc' folder to build folder...")
  replace_dir(File.join('etc','buffers'), File.join('build','sonic-pi','etc','buffers'))
  replace_dir(File.join('etc','doc'), File.join('build','sonic-pi','etc','doc')) # Only needed at build time
  replace_dir(File.join('etc','examples'), File.join('build','sonic-pi','etc','examples')) # Only needed at build time
  replace_dir(File.join('etc','samples'), File.join('build','sonic-pi','etc','samples'))
  replace_dir(File.join('etc','synthdefs'), File.join('build','sonic-pi','etc','synthdefs'))
  #replace_dir(File.join('..','etc','snippets'), File.join('sonic-pi','etc','snippets')) # Not currently used
  #replace_dir(File.join('..','etc','wavetables'), File.join('sonic-pi','etc','wavetables')) # Not currently used
end

# Build osmid

desc "Build Sonic Pi Erlang files"
task :build_erlang_files, [:sonic_pi_root] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
  when :linux
    install_packages(["erlang"], SPI_BUILD_CONFIG.pkg_manager) if (all_dependencies_installed == false)
    info("Building Erlang files...")
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
  info("Compiling Sonic Pi server extensions...")
  ruby File.join(args.sonic_pi_root,'app','server','ruby','bin','compile-extensions.rb')
end

desc "Build Sonic Pi documention"
task :build_documentation, [:sonic_pi_root] do |t, args|
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  info("Building documentation and applying translations...")
  ruby File.join(args.sonic_pi_root,'app','server','ruby','bin','i18n-tool.rb') + " -t"
end

desc "Build Sonic Pi QT docs"
task :build_qt_docs, [:sonic_pi_root] do |t, args|
	args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))

  info("Building Sonic Pi QT docs...")
  Fileutils.cp_f(File.join(args.sonic_pi_root,"app","gui","qt","ruby_help.tmpl"), File.join(args.sonic_pi_root,"app","gui","qt","ruby_help.h"))
  ruby File.join(args.sonic_pi_root,'app','server','ruby','bin','qt-doc.rb') + ' -o ' + File.join(args.sonic_pi_root,'app','gui','qt','ruby_help.h')
end

desc "Build Sonic Pi QT GUI"
task :build_gui, [:make_jobs, :sonic_pi_root] do |t, args|
	args.with_defaults(:make_jobs => 1)
  args.with_defaults(:sonic_pi_root => File.join(File.expand_path(Dir.pwd), "build", "sonic-pi"))
  
  OS = ask_if_raspbian if (OS == :linux_arm)

  case OS
  when :raspberry
  when :linux
    install_packages(Dependencies::Linux.gui, SPI_BUILD_CONFIG.pkg_manager) if (all_dependencies_installed == false)
    info("Building QT GUI...")
    exec_commands([
      %Q(cd #{args.sonic_pi_root}/app/gui/qt),
      %Q(lrelease SonicPi.pro),
      %Q(qmake -qt=qt5 SonicPi.pro),
      %Q(make -j#{args.make_jobs})
    ])

  when :windows
  	exec_win_commands([
			%Q(cd #{args.sonic_pi_root}\\app\\gui\\qt),
			%Q(c:\\Qt\\5.5\\msvc2013\\bin\\lrelease.exe SonicPi.pro),
			%Q(c:\\Qt\\5.5\\msvc2013\\bin\\qmake.exe SonicPi.pro),
			%Q(nmake),
		
			%Q(cd release),
			%Q(c:\\Qt\\5.5\\msvc2013\\bin\\windeployqt sonic-pi.exe -printsupport),
			# Dynamic libraries to link to at runtime
			%Q(copy c:\\qwt-6.1.3\\lib\\qwt.dll .\\),
			%Q(copy c:\\QScintilla_gpl-2.9.3\\Qt4Qt5\\release\\qscintilla2.dll .\\),
			%Q(copy c:\\Qt\\5.5\\msvc2013\\bin\\Qt5OpenGL.dll .\\)
		])
  when :macos
  end
end

desc "Clean build folder"
task :clean_build_folder do
  info("Cleaning build folder...")
  FileUtils.rm_rf(File.join('build','sonic-pi','etc','docs',''))
  FileUtils.rm_rf(File.join('build','sonic-pi','etc','examples',''))
  make_clean(File.join('build','sonic-pi','app','gui','qt',''))
  info("Deleting Qt GUI source code from build folder...")
  FileUtils.rm_rf(Dir[File.join('build','sonic-pi','app','gui','qt','**','*.cpp')])
  FileUtils.rm_rf(Dir[File.join('build','sonic-pi','app','gui','qt','**','*.h')])
  FileUtils.rm_rf(Dir[File.join('build','sonic-pi','app','gui','qt','**','*.hpp')])
end



