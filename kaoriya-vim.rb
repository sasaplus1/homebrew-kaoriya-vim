class KaoriyaVim < Formula
  desc "KaoriYa Vim"
  homepage "https://www.kaoriya.net/software/vim/"
  url "https://github.com/koron/vim-kaoriya.git", :branch => "master"
  version "8.2.0087"
  head "https://github.com/koron/vim-kaoriya.git", :branch => "develop"

  depends_on "autoconf" => :build
  depends_on "coreutils" => :build
  depends_on "gnu-sed" => :build
  depends_on "lua@5.1" => :build
  depends_on "luajit" => :build
  depends_on "make" => :build
  depends_on "python" => :build

  depends_on "gettext"

  conflicts_with "macvim"
  conflicts_with "vim"

  test do
    system "false"
  end
end
