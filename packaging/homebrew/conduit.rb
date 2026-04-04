class Conduit < Formula
  desc "Network relay with integrated process masquerading"
  homepage "https://real-fruit-snacks.github.io/Conduit"
  url "https://github.com/Real-Fruit-Snacks/Conduit/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "" # Will be filled after release
  license "GPL-2.0-only WITH OpenSSL-exception"

  depends_on "openssl@3"
  depends_on "readline"

  def install
    cd "socat-repo" do
      system "./configure",
             "--prefix=#{prefix}",
             "--mandir=#{man}",
             "CFLAGS=-I#{Formula["openssl@3"].opt_include}",
             "LDFLAGS=-L#{Formula["openssl@3"].opt_lib}"
      system "make", "conduit"
      bin.install "conduit"
    end

    # Install man page
    man1.install "conduit.1"

    # Install shell completions
    bash_completion.install "completions/conduit.bash" => "conduit"
    zsh_completion.install "completions/_conduit"

    # Install examples
    pkgshare.install "examples"
  end

  test do
    # Test help output
    assert_match "Network relay with process masquerading", shell_output("#{bin}/conduit -h 2>&1")

    # Test version output
    assert_match "socat version", shell_output("#{bin}/conduit -V 2>&1")

    # Test masquerading options are available
    help_output = shell_output("#{bin}/conduit -h 2>&1")
    assert_match "-Mk", help_output
    assert_match "-Ms", help_output
  end

  def caveats
    <<~EOS
      Conduit is a security tool intended for authorized testing only.

      Example scripts are installed to:
        #{pkgshare}/examples

      Shell completions are automatically installed for:
        - Bash: #{bash_completion}/conduit
        - Zsh: #{zsh_completion}/_conduit

      Man page: man conduit

      For authorized security operations, use masquerading options:
        conduit -Mk   # Kernel worker masquerade
        conduit -Ms   # Systemd service masquerade
        conduit -Mb   # Launchd masquerade (macOS)
        conduit -Mm   # mDNSResponder masquerade (macOS)
    EOS
  end
end
