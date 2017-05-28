class Hyperkit < Formula
  require "open3"

  desc "Lightweight virtualization hypervisor for MacOS"
  homepage "https://github.com/moby/hyperkit"

  def self.version_from_git(build_path, branch = "master")
    command = <<-CMD.undent
      \\cd "#{build_path}"; \
      \\git log -1 --pretty=format:"%cd-%h" --date=short #{branch}
    CMD
    version_string, _stderr, _status = Open3.capture3(command.chomp)
    version_string.split("-", 3).join("").split("-")
  end

  def self.version_from_url(url)
    url.scan(/hyperkit-([\d]{8})-([A-Fa-f\d]+).tar.gz$/).first
  end

  stable do
    url "https://dl.bintray.com/markeissler/homebrew/hyperkit/hyperkit-20170515-fa78d94.tar.gz"
    sha256 "5bdb9e9bdfd00813c0f01c2b918a7af1e15c79e08b83c8369995592cc3999054"
    # correct version auto-detection fails, so we set it explicitly
    version(Hyperkit.version_from_url(url).join("-"))
  end

  bottle do
    root_url "http://dl.bintray.com/markeissler/homebrew/bottles"
    cellar :any_skip_relocation
    sha256 "6de3049ceb63dc441e9cd9402884b05d27dbf2e3664014a2550d1454ef1cb657" => :sierra
    sha256 "caab21f5aa36d9d240fb0399b8b30be4e5d3b34b1107b70b7886a8ed47fbd22f" => :el_capitan
    sha256 "d673655dce12caa88e22b356ec5109211e8b12e0ba4e9d501c9737a6966a6922" => :yosemite
  end

  head do
    url "https://github.com/moby/hyperkit.git", :branch => "master"
  end

  depends_on "opam" => :run
  depends_on "libev" => :run

  resource "tinycorelinux" do
    url "https://dl.bintray.com/markeissler/homebrew/hyperkit-kernel/tinycorelinux_8.x.tar.gz"
    sha256 "560c1d2d3a0f12f9b1200eec57ca5c1d107cf4823d3880e09505fcd9cd39141a"
  end

  def install
    ohai "... Installing hyperkit dependencies with OPAM. This might take a while."

    system <<-CMD.undent
      export OPAMYES=1
      opam init
      eval "$(opam config env)"
      opam install uri qcow.0.9.5 mirage-block-unix.2.7.0 conf-libev logs fmt mirage-unix
    CMD

    ohai "... Dependencies installed."

    # update the Makefile to set version to YYYYmmdd-sha1
    if build.head?
      version, sha1 = Hyperkit.version_from_git(buildpath, "master")
    else
      # no need to re-parse version, we already set it in stable declaration above
      version, sha1 = stable.version.to_s.split("-")
    end
    if version.nil? || version.empty? || sha1.nil? || sha1.empty?
      odie "Couldn't figure out which version we're building!"
    end
    update_makefile(buildpath, version, sha1)

    system "make"

    bin.install "build/hyperkit"
    man1.install "hyperkit.1"
  end

  test do
    #
    # Download tinycorelinux kernel and initrd, boot system, check for prompt.
    #
    ohai "... Running tests."

    resource("tinycorelinux").stage do |context|
      tmpdir = context.staging.tmpdir
      path_resource_versioned = Dir.glob(tmpdir.join("tinycorelinux_[0-9]*"))[0]
      cp(File.join(path_resource_versioned, "vmlinuz"), testpath)
      cp(File.join(path_resource_versioned, "initrd.gz"), testpath)
    end

    # boot tinycorelinux and check for a prompt
    (testpath/"test_hyperkit.exp").write strip_heredoc(<<-EOS)
      #!/usr/bin/env expect -d

      set KERNEL "./vmlinuz"
      set KERNEL_INITRD "./initrd.gz"
      set KERNEL_CMDLINE "earlyprintk=serial console=ttyS0"

      set MEM {512M}
      set PCI_DEV1 {0:0,hostbridge}
      set PCI_DEV2 {31,lpc}
      set LPC_DEV {com1,stdio}
      set ACPI {-A}

      spawn #{bin}/hyperkit $ACPI -m $MEM -s $PCI_DEV1 -s $PCI_DEV2 -l $LPC_DEV -f kexec,$KERNEL,$KERNEL_INITRD,$KERNEL_CMDLINE
      set pid [exp_pid]
      set timeout 20

      expect {
        timeout { puts "FAIL boot"; exec kill -9 $pid; exit 1 }
        "\\r\\ntc@box:~$ "
      }

      send "sudo halt\\r\\n";

      expect {
        timeout { puts "FAIL shutdown"; exec kill -9 $pid; exit 1 }
        "reboot: System halted"
      }

      expect eof

      puts "\\nPASS"
    EOS

    system "expect", "test_hyperkit.exp"
  end

  private

  # A more flexible version of undent, compress removes newlines
  def strip_heredoc(text, compress = false)
    stripped = text.gsub(/^#{text.scan(/^\s*/).min_by(&:length)}/, "")
    compress ? stripped.tr("\n", " ").chop : stripped
  end

  def update_makefile(build_path, version, sha1)
    system strip_heredoc(<<-CMD, true)
      \\sed -i".bak"
      -e "s/GIT_VERSION[\ ]*:=.*/GIT_VERSION := #{version}-#{sha1}/g"
      -e "s/GIT_VERSION_SHA1[\ ]:=.*/GIT_VERSION_SHA1 := #{sha1}/g"
      "#{build_path}/Makefile"
    CMD
  end
end