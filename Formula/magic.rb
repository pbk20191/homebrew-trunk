class Magic < Formula
  desc "OpenSource VLSI Layout Tool"
  homepage "http://opencircuitdesign.com/magic/"
  url "http://opencircuitdesign.com/magic/archive/magic-8.3.460.tgz"
  sha256 "322c30095a5b984b86c18dfafdcb5f0f4c4ae112f9b6894cfd83d21cb233ae09"
  license "HPND-UC"

  head do
    url "git://opencircuitdesign.com/magic", branch: "master"
  end
  depends_on :macos
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libglu"
  depends_on "libice"
  depends_on "libx11"
  depends_on "libxext"
  depends_on "libxi"
  depends_on "libxmu"
  depends_on "libxrender"
  depends_on "mesa"
  depends_on "python3"
  depends_on "sethrfore/r-srf/cairo-x11"
  depends_on "sethrfore/r-srf/tcl-tk-x11"
  # depends_on cask: "xquartz"

  def install
    tcltk = Formula["sethrfore/r-srf/tcl-tk-x11"]
    cairo = Formula["sethrfore/r-srf/cairo-x11"]

    args = %W[
      --with-tcl=#{tcltk.opt_prefix}
      --with-tk=#{tcltk.opt_prefix}
      --with-cairo=#{cairo.opt_include}
      --x-includes=#{include}/X11
      --x-libraries=#{lib}/X11
    ]
    ENV["CPPFLAGS"] = " -I#{Formula["freetype"].opt_include}/freetype2 "
    ENV["LDFLAGS"] = " -L#{Formula["cairo"].opt_lib}"
    ENV["X11_LDFLAGS"] = "-L#{lib}"

    system "./configure", *std_configure_args, *args
    system "make", "database/database.h"
    system "make", "-j#{Hardware::CPU.cores}"
    system "make", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test magic`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
