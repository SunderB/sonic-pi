#cmd = `sudo apt-get install -y \
#     g++ ruby ruby-dev pkg-config git build-essential libjack-jackd2-dev \
#     libsndfile1-dev libasound2-dev libavahi-client-dev libicu-dev \
#     libreadline6-dev libfftw3-dev libxt-dev libudev-dev cmake libboost-dev \
#     libqwt-qt5-dev libqt5scintilla2-dev libqt5svg5-dev qt5-qmake qt5-default \
#     qttools5-dev qttools5-dev-tools qtdeclarative5-dev libqt5webkit5-dev \
#     qtpositioning5-dev libqt5sensors5-dev qtmultimedia5-dev libffi-dev \
#     curl python erlang-base`

class dependencies {
  class linux {
    def :supercollider do
      dep = []
      dep.push("curl")
      dep.push("git")

      dep.push("gcc >= 4.8.0")
      #dep.push("g++")
      dep.push("make")
      dep.push("cmake >= 2.8.11")
      dep.push("libc6-dev")
      dep.push("libjack-jackd2-dev")
      dep.push("libsndfile1-dev >= 1.0.0")
      dep.push("libasound2-dev")
      dep.push("libavahi-client-dev")
      dep.push("libicu-dev")
      dep.push("libreadline6-dev")
      dep.push("libfftw3-dev")
      dep.push("libxt-dev")
      dep.push("libudev-dev")
      dep.push("pkg-config")

      dep.push("qt5-default")
      dep.push("qt5-qmake")
      dep.push("qttools5-dev")
      dep.push("qttools5-dev-tools")
      dep.push("qtdeclarative5-dev")
      dep.push("libqt5webkit5-dev")
      return dep
    end

    def :server do
      dep = []
      dep.push("curl")
      dep.push("git")

      dep.push("ruby")
      dep.push("ruby-dev")
      dep.push("python")
      dep.push("erlang-base")
      return dep
    end

    def :gui do
      dep = []
      dep.push("curl")
      dep.push("git")

      dep.push("g++")
      dep.push("make")
      dep.push("cmake")
      dep.push("qt5-default")
      dep.push("qt5-qmake")
      dep.push("qttools5-dev")
      dep.push("qttools5-dev-tools")
      dep.push("qtdeclarative5-dev")
      dep.push("libqt5webkit5-dev")
      dep.push("qtpositioning5-dev")
      dep.push("libqt5sensors5-dev")
      dep.push("qtmultimedia5-dev")
      dep.push("libxt-dev")
      dep.push("libboost-dev")
      dep.push("libqwt-qt5-dev")
      dep.push("libqt5scintilla2-dev")
      dep.push("libqt5svg5-dev")
      dep.push("libffi-dev")
      return dep
    end
  }
}

#dep = []
#dep.push("g++")
#dep.push("ruby")
#dep.push("ruby-dev")
#dep.push("pkg-config")
#dep.push("git")
#dep.push("libjack-jackd2-dev")
#dep.push("libsndfile1-dev")
#dep.push("libasound2-dev")
#dep.push("libavahi-client-dev")
#dep.push("libicu-dev")
#dep.push("libreadline6-dev")
#dep.push("libfftw3-dev")
#dep.push("libxt-dev")
#dep.push("libudev-dev")
#dep.push("libxt-dev")
#dep.push("cmake")
#dep.push("libboost-dev")
#dep.push("libqwt-qt5-dev")
#dep.push("libqt5scintilla2-dev")
#dep.push("libqt5svg5-dev")
#dep.push("qt5-qmake")
#dep.push("qt5-default")
#dep.push("qttools5-dev")
#dep.push("qttools5-dev-tools")
#dep.push("qtdeclarative5-dev")
#dep.push("libqt5webkit5-dev")
#dep.push("qtpositioning5-dev")
#dep.push("libqt5sensors5-dev")
#dep.push("qtmultimedia5-dev")
#dep.push("libffi-dev")
#dep.push("curl")
#dep.push("python")
#dep.push("erlang-base")
