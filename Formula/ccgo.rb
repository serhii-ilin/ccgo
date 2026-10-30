class Ccgo < Formula
  desc "Launch Claude Code against OpenCode Go models (DeepSeek, MiniMax, Qwen, Kimi)"
  homepage "https://github.com/serhii-ilin/ccgo"
  url "https://github.com/serhii-ilin/ccgo/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "e9ed211cfba4f99af1e7f08ca9bc53543aeefe6095e5d02e76bd0cb0990fd7ed"
  license "MIT"
  head "https://github.com/serhii-ilin/ccgo.git", branch: "main"

  def install
    libexec.install "lib/ccgo.sh", "lib/providers.sh"
    bin.install "bin/ccgo"
  end

  def caveats
    <<~EOS
      Set your OpenCode key before running (never commit it):
        export OPENCODE_API_KEY=...
      Requires the Claude Code CLI (`claude`).
    EOS
  end

  test do
    assert_match "OpenCode Go", shell_output("#{bin}/ccgo list")
  end
end
