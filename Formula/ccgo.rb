class Ccgo < Formula
  desc "Launch Claude Code against OpenCode Go models (DeepSeek, MiniMax, Qwen, Kimi)"
  homepage "https://github.com/serhii-ilin/ccgo"
  url "https://github.com/serhii-ilin/ccgo/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "e7a0efc8ec1d9222f19cefa82d1018768e757628c0335621a3870c6330440578"
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
    assert_match version.to_s, shell_output("#{bin}/ccgo --version")
  end
end
