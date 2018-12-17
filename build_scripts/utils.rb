require 'fileutils'

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

OS = ask_if_raspbian if (OS == :linux_arm)

_SONIC_PI_ROOT = File.join(File.expand_path(Dir.pwd),"..","build","sonic-pi")

class Config
	attr_accessor :pkg_manager
	attr_accessor :checkinstall
	attr_accessor :distro
	attr_accessor :make_jobs
	
	def initialize
		@@pkg_manager = :invalid
		@@checkinstall = :invalid
		@@distro = :none
	end
	
	# The package manager being used (Linux only)
	def pkg_manager
		return @@pkg_manager
	end
	def pkg_manager=(new)
		@@pkg_manager = new
	end
	
	# Whether or not checkinstall should be used when installing programs from source (on Linux)
	def checkinstall
		return @@checkinstall
	end
	def checkinstall=(new)
		if (new == true)
			@@checkinstall = true
		else
			@@checkinstall = false
		end
	end
	
	# The GNU/Linux distro that's being used (Linux only)
	def distro
		return @@distro
	end
	def distro=(new)
		@@distro = new
	end
end

SPI_BUILD_CONFIG = Config.new()

def make_clean(dir)
  info("### Running make clean in #{dir}")
  if File.exist?("#{dir}/Makefile") then
    exec_bash("cd #{dir} && make clean")
    FileUtils.rm_rf "#{dir}/Makefile"
  end
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
    puts("1: apt (for Debian, Ubuntu and other Debian based distros)")
    puts("2: pacman (for Arch Linux and some other distros)")

    m = case STDIN.gets.chomp
    when "1"
      :apt
    when "2"
    	:pacman
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
  when :pacman
  	cmd = exec_bash(%Q(pacman -S #{package_names.join(" ")}))
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
        # The version is isn't the version specified in the dependencies!
        return false
      end
      
    when "<="
      if ((version1[i].to_i <= version2[i].to_i) == false)
        # The version is more than the version specified in the dependencies!
        return false
      end
      
    when ">"
      if ((version1[i].to_i > version2[i].to_i) == false)
        # The version is less than the version specified in the dependencies!
        return false
      end
      
		when "<"
      if ((version1[i].to_i < version2[i].to_i) == false)
        # The version is more than the version specified in the dependencies!
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
  when :pacman
  	var = exec_bash(%Q(pacman -Si #{package}| grep '^Version         :'))
  	ver = ver.split("\n")[0] # Get the first line of the output
    ver = ver.to_s
    
    ver.slice!("Version         : ") # Remove the 'Version         : ' bit
    ver = ver.split("+")[0]
    ver = ver.split("-")[0]
    ver = ver.split("~")[0]
    ver = ver.split(":")[1]
    
    puts(ver)
    return ver
  else
  end
end

def info(text)
  text_cyan = '\033[1;36m'
  text_nc = '\033[0m'
  exec_bash(%Q(echo -e \\"#{text_cyan}#{text}#{text_nc}\\"))
end

def exec_commands(commands)
  exec_bash(commands.join(" && "))
end

def exec_bash(command)
  #puts('bash -licv' + command)
  #result = `bash -licv "#{command}"`

  puts(`tput setaf 11` + "Executing command: " + command + `tput sgr0`) # for debugging
  result = `sh -c "#{command}"`
  puts(result.to_s)
  return result
end

def replace_dir(dir1, dir2)
  #puts(File.expand_path(dir1))
  #puts(File.expand_path(dir2))
  FileUtils.rm_rf(dir2)
  create_dir(dir2)
  FileUtils.copy_entry(dir1, dir2, remove_destination=true)
end

def create_dir(path)
  FileUtils.mkdir_p(path) if (File.directory?(path) == false)
end
