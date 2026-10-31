class Ccgo < Formula
  desc "Launch Claude Code against OpenCode Go models (DeepSeek, MiniMax, Qwen, Kimi)"
  homepage "https://github.com/serhii-ilin/ccgo"
  url "https://github.com/serhii-ilin/ccgo/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "80586d6411167bb28e74c2c8247d2e06b432e194d6091cb71c1332675107c02a"
  license "MIT"
  head "https://github.com/serhii-ilin/ccgo.git", branch: "main"

  def install
    bin.install "bin/ccgo"
  end

  def post_install
    chmod 0555, bin/"ccgo"
  end

  def caveats
    <<~EOS
      Set your OpenCode key before running (never commit it):
        export OPENCODE_API_KEY=...
      Requires the Claude Code CLI (`claude`).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ccgo --version")
  end
end
