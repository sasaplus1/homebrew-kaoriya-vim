require "macho"

class KaoriyaVim < Formula
  desc "KaoriYa Vim"
  homepage "https://www.kaoriya.net/software/vim/"
  url "https://github.com/koron/vim-kaoriya.git", :branch => "master"
  version "8.2.0087"
  head "https://github.com/koron/vim-kaoriya.git", :branch => "develop"

  depends_on "autoconf" => :build
  depends_on "coreutils" => :build
  depends_on "lua@5.1" => :build
  depends_on "luajit" => :build
  depends_on "make" => :build
  depends_on "python" => :build

  depends_on "gettext"

  conflicts_with "macvim"
  conflicts_with "vim"

  resource "guilt" do
    # NOTE: default branch name is edge
    url "https://github.com/koron/guilt.git", :branch => "edge"
  end

  def install
    resource("guilt").stage do
      inreplace "guilt", /\breadlink\b/, "greadlink"
      system "make", "PREFIX=#{buildpath}/guilt", "install"
    end

    ENV.prepend_create_path "PATH", "#{buildpath}/guilt/bin"

    vim_version = `printf -- '%b' 'all:\n\t@printf -- $(VIM_VER)' | make -f VERSION -f -`

    # in vim-kaoriya/vim
    cd "vim" do
      system "git", "checkout", "-b", "v#{vim_version}"
      system "git", "config", "--local", "guilt.patchesdir", "../patches"
      system "guilt", "init"
    end

    # in vim-kaoriya/patches
    cd "patches" do
      Dir.glob("master/*") do |file|
        cp file, "v#{vim_version}"
      end
    end

    # in vim-kaoriya/vim/src
    cd "vim/src" do
      system "guilt", "push", "--all"
    end

    # in vim-kaoriya/vim
    cd "vim" do
      ENV["LUA_PREFIX"] = HOMEBREW_PREFIX
      ENV["CFLAGS"] = "-I#{HOMEBREW_PREFIX/"opt/gettext/include"}"
      ENV["LDFLAGS"] = "-L#{HOMEBREW_PREFIX/"opt/gettext/lib"}"

      params = %W[
        --prefix=#{prefix}
        --enable-fail-if-missing
        --disable-smack
        --disable-selinux
        --disable-xsmp
        --disable-xsmp-interact
        --enable-luainterp=dynamic
        --enable-pythoninterp=dynamic
        --enable-python3interp=dynamic
        --enable-cscope
        --disable-netbeans
        --enable-terminal
        --enable-multibyte
        --disable-rightleft
        --disable-arabic
        --enable-gui=no
        --with-compiledby=sasa+1
        --with-features=huge
        --with-luajit
        --without-x
        --with-tlib=ncurses
      ]

      system "./configure", *params
      system "make", "DATADIR=#{share}"
      system "make", "install"
    end

    # in vim-kaoriya/build/freebsd
    cd "build/freebsd" do
      user = `printf -- '%b' "$(whoami)"`

      inreplace "Makefile", /\broot\b/, user
      system "make", "VIM_DIR=#{share/"vim"}", "kaoriya-install"
    end
  end

  def get_dylib_versions(version)
    # https://stackoverflow.com/a/14796228
    { "major" => version >> 16, "minor" => (version >> 8) & 0xff, "patch" => (version & 0xff) }
  end

  test do
    # NOTE: brew audit says: `Use ruby-macho instead of calling "otool"`
    # system "otool", "-L", "#{bin/"vim"}"
    file = MachO::MachOFile.new(bin/"vim")

    printf "#{file.filename}:\n"

    file.dylib_load_commands.each do |command|
      compat = get_dylib_versions(command.compatibility_version).values.join(".")
      current = get_dylib_versions(command.current_version).values.join(".")

      printf "\t%<name>s (compatibility version %<compat>s, current version %<current>s)\n",
        :name => command.name, :compat => compat, :current => current
    end

    system bin/"vim", "--version"
  end
end
