class Ccgo < Formula
  desc "Launch Claude Code against OpenCode Go models (DeepSeek, MiniMax, Qwen, Kimi)"
  homepage "https://github.com/serhii-ilin/ccgo"
  url "https://github.com/serhii-ilin/ccgo/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "305b24428cd3c7d8f7fc5f7398d50c4e74d18ee5fd56c98bb5d021ac9e424e78"
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
