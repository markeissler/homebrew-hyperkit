  class Hyperkit < Formula
    require 'open3'

    desc "A toolkit for embedding hypervisor capabilities in your application"
    homepage "https://github.com/moby/hyperkit"

    # A more flexible version of undent, compress removes newlines
    class ::String
      def strip_heredoc(compress = false)
        stripped = gsub(/^#{scan(/^\s*/).min_by(&:length)}/, "")
        compress ? stripped.gsub(/\n/," ").chop : stripped
      end
    end

    def self.version_from_git(build_path, branch="master")
      command = <<-CMD.undent
        \\cd "#{build_path}"; \
        \\git log -1 --pretty=format:"%cd-%h" --date=short #{branch}
      CMD
      version_string, _stderr, _status = Open3.capture3(command.chomp())
      version_string.split("-", 3).join("").split("-")
    end

    def self.version_from_url(url)
      url.scan(/hyperkit-([\d]{8})-([A-Fa-f\d]+).tar.gz$/).first
    end

    stable do
      url "https://dl.bintray.com/markeissler/homebrew/hyperkit/hyperkit-20170515-fa78d94.tar.gz"
      sha256 "5bdb9e9bdfd00813c0f01c2b918a7af1e15c79e08b83c8369995592cc3999054"
      # correct version auto-detection fails, so we set it explicitly
      self.version(Hyperkit.version_from_url(self.url).join("-"))
    end

    head do
      url "https://github.com/moby/hyperkit.git", :branch => 'master'
    end

    depends_on "opam" => :run
    depends_on "libev" => :run

    def install
      ohai "... Installing dependencies with OPAM. This might take a while."

      system <<-CMD.undent
        export OPAMYES=1
        opam init
        eval "$(opam config env)"
        opam install uri qcow.0.9.5 mirage-block-unix.2.7.0 conf-libev logs fmt mirage-unix
      CMD

      ohai "... Dependencies installed."

      # update the Makefile to set version to YYYYmmdd-sha1
      unless build.bottle?
        if build.head?
          version, sha1 = Hyperkit.version_from_git(self.buildpath, "master")
        else
          # version, sha1 = Hyperkit.version_from_url(self.stable.url)
          version, sha1 = self.stable.version.to_s.split("-")
        end
        if (version.nil? or version.empty? or sha1.nil? or sha1.empty?)
          odie "Couldn't figure out which version we're building!"
        end
        update_makefile(self.buildpath, version, sha1)
      end

      system "make"

      bin.install "build/hyperkit"
      man1.install "hyperkit.1"
    end

    test do
      # `test do` will create, run in and delete a temporary directory.
      #
      # This test will fail and we won't accept that! It's enough to just replace
      # "false" with the main program this formula installs, but it'd be nice if you
      # were more thorough. Run the test with `brew test hyperkit`. Options passed
      # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
      #
      # The installed folder is not in the path, so use the entire path to any
      # executables being tested: `system "#{bin}/program", "do", "something"`.
      # system "false"
      ohai "... Running tests."

      # @TODO: create a script to patch tinylinux
      # @TODO: upload patched tinylinux vmlinuz and initrd.gz to bintray
      # @TODO: update tinycore_install.sh to copy these resources in tmp so we can grab them for the test.

      (testpath/"tinycore_install.sh").write <<-EOS.undent
        #!/usr/bin/env sh
        set -e

        # These are binaries from a mirror of
        #  http://tinycorelinux.net
        # with the following patch applied:
        # Upstream source is available http://www.tinycorelinux.net/6.x/x86/release/src/
        #BASE_URL="http://www.tinycorelinux.net/"

        BASE_URL="http://distro.ibiblio.org/tinycorelinux/"

        # TMP_DIR=$(mktemp -d -t hyperkit)
        TMP_DIR="#{testpath}"

        echo Downloading tinycore linux (patched)
        #curl -s -o vmlinuz "${BASE_URL}/6.x/x86/release/distribution_files/vmlinuz64"
        #curl -s -o "${TMP_DIR}"/initrd.gz "${BASE_URL}/6.x/x86/release/distribution_files/core.gz"
        cp /tmp/hyperkit-imgs/vmlinuz "${TMP_DIR}/vmlinuz"
        cp /tmp/hyperkit-imgs/initrd.gz "${TMP_DIR}/initrd.gz"
      EOS

      system "sh", "tinycore_install.sh"

      (testpath/"test_hyperkit.exp").write <<-EOS.strip_heredoc
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
      def update_makefile(build_path, version, sha1)
        system <<-CMD.strip_heredoc(true)
          \\sed -i".bak"
          -e "s/GIT_VERSION[\ ]*:=.*/GIT_VERSION := #{version}-#{sha1}/g"
          -e "s/GIT_VERSION_SHA1[\ ]:=.*/GIT_VERSION_SHA1 := #{sha1}/g"
          "#{build_path}/Makefile"
        CMD
      end
  end
