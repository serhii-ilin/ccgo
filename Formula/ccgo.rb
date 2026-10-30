class Ccgo < Formula
  desc "Launch Claude Code against OpenCode Go models (DeepSeek, MiniMax, Qwen, Kimi)"
  homepage "https://github.com/serhii-ilin/ccgo"
  url "https://github.com/serhii-ilin/ccgo/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "cc22fd153306baa77e72308fdf16c7e3b286dc33a09a0a01048131839bc3d1eb"
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
