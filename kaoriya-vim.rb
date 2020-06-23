class KaoriyaVim < Formula
  desc "KaoriYa Vim"
  homepage "https://www.kaoriya.net/software/vim/"
  url "https://github.com/koron/vim-kaoriya.git", :branch => "master"
  version "8.2.0087"
  head "https://github.com/koron/vim-kaoriya.git", :branch => "develop"

  test do
    system "false"
  end
end
