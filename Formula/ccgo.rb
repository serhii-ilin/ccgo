class Ccgo < Formula
  desc "Launch Claude Code against OpenCode Go models (DeepSeek, MiniMax, Qwen, Kimi)"
  homepage "https://github.com/serhii-ilin/ccgo"
  url "https://github.com/serhii-ilin/ccgo/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "ffbb3cc50ddd0045206bc0fd184455c70b5690f94ed62cbdc86b648dcd5ef17a"
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
