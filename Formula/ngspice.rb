class Ngspice < Formula
  desc "Spice circuit simulator"
  homepage "https://ngspice.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/ngspice/ng-spice-rework/42/ngspice-42.tar.gz"
  sha256 "737fe3846ab2333a250dfadf1ed6ebe1860af1d8a5ff5e7803c772cc4256e50a"
  license :cannot_represent

  livecheck do
    url :stable
    regex(%r{url=.*?/ngspice[._-]v?(\d+(?:\.\d+)*)\.t}i)
  end

  # bottle do
  #   sha256 arm64_ventura:  "8e36bc3e8ab359c91e0f0b2c01cc604e158526b711e11289c5ae8e186266a1cd"
  #   sha256 arm64_monterey: "f902ee20c956ce7cfcfe714c707faa27a9f97efaf0937fb5099927857f9903b0"
  #   sha256 arm64_big_sur:  "db4112cb7dd18fe865980f04cc5b52d4d202fe6eaa96be28f6f0a30c5873fc51"
  #   sha256 ventura:        "836200d6dd7bbabac59e51d73bdd2048e5e4173c6919a9a5904b161178ab3632"
  #   sha256 monterey:       "ce332690f0c8fd65b69ce3ae665911ea014b011e6796c21b2e64b0fff3b83f88"
  #   sha256 big_sur:        "fe20b393cb57a19b05b0809f2ccf8ab5282aa193b270b1da7ae79630ec2573d1"
  #   sha256 x86_64_linux:   "07a2aa97edc37e0e379fc4728563314a72ca110e1d564acd8bafc2bd94649e65"
  # end

  head do
    url "https://git.code.sf.net/p/ngspice/ngspice.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "fftw"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libice"
  depends_on "libngspice"
  depends_on "libx11"
  depends_on "libxaw"
  depends_on "libxext"
  depends_on "libxft"
  depends_on "libxmu"
  depends_on "libxrender"
  depends_on "libxt"
  depends_on "ncurses"
  depends_on "readline"
  depends_on "libomp" => :optional
  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  # depends_on cask: "xquartz"

  def install
    system "./autogen.sh" if build.head?

    args = %w[
      --with-readline=yes
      --enable-xspice
      --with-x
      --enable-cider
      --enable-pss
      --enable-osdi
      --enable-predictor
    ]
    ENV["CPPFLAGS"] = " -I#{Formula["freetype"].opt_include}/freetype2"
    if build.with? "libomp"
      args = args << "--enable-openmp"
      ENV["LDFLAGS"] = " -L#{Formula["libomp"].opt_lib} -lomp"
      ENV["CPPFLAGS"] += " -I#{Formula["libomp"].opt_include} -Xpreprocessor -fopenmp"
    end

    system "./configure", *std_configure_args, *args
    system "make", "-j4"
    system "make", "install"

    # fix references to libs
    inreplace pkgshare/"scripts/spinit", lib/"ngspice/", Formula["libngspice"].opt_lib/"ngspice/"

    # remove conflict lib files with libngspice
    rm_rf Dir[lib/"ngspice"]
  end

  test do
    (testpath/"test.cir").write <<~EOS
      RC test circuit
      v1 1 0 1
      r1 1 2 1
      c1 2 0 1 ic=0
      .tran 100u 100m uic
      .control
      run
      quit
      .endc
      .end
    EOS
    system "#{bin}/ngspice", "test.cir"
  end
end
