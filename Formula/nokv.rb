# Copyright 2024-2026 The NoKV Authors.
# SPDX-License-Identifier: Apache-2.0

class Nokv < Formula
  desc "Metadata control plane and Workbench MCP server for agent workspaces"
  homepage "https://nokv.io/"
  url "https://github.com/NoKV-Lab/NoKV/releases/download/v0.12.1/nokv-0.12.1-source.tar.gz"
  sha256 "c9c743aef091312595f90f392d1bfadea6bfc24ebcf6e7306ec7529c44550a2d"
  license "Apache-2.0"
  version_scheme 1

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  def install
    ENV["NOKV_BUILD_GIT_COMMIT"] = "6be80629aa9ba481f0e52bf57f83f7d6ae9e8542"
    ENV["NOKV_BUILD_CARGO_LOCK_SHA256"] = "ae6fefafd795f772341249f4cf71759c807b8a0f85287874ca1a0410dce8d390"
    ENV["NOKV_BUILD_HOLT_VERSION"] = "0.8.7"
    ENV["NOKV_BUILD_HOLT_SOURCE"] = "registry+https://github.com/rust-lang/crates.io-index"
    ENV["NOKV_BUILD_HOLT_CHECKSUM"] = "c0429a061efcfb85c11a21a62eaf20a2410e014ca6cc5a987b5a8c59e3984463"

    system "cargo", "install", *std_cargo_args(path: "crates/nokv")
  end

  test do
    assert_equal "nokv 0.12.1", shell_output("#{bin}/nokv --version").strip

    identity = JSON.parse(shell_output("#{bin}/nokv version --json"))
    assert_equal "0.12.1", identity.fetch("version")
    assert_equal "6be80629aa9ba481f0e52bf57f83f7d6ae9e8542", identity.fetch("git_commit")
    assert_equal "ae6fefafd795f772341249f4cf71759c807b8a0f85287874ca1a0410dce8d390",
                 identity.fetch("cargo_lock_sha256")
    assert_equal "0.8.7", identity.dig("holt", "version")
    assert_equal "registry+https://github.com/rust-lang/crates.io-index", identity.dig("holt", "source")
    assert_equal "c0429a061efcfb85c11a21a62eaf20a2410e014ca6cc5a987b5a8c59e3984463", identity.dig("holt", "checksum")
    assert_equal "nokv.workbench.mcp_input_schemas.v1", identity.fetch("workbench_contract_schema")
    assert_equal 18, identity.fetch("workbench_tool_count")

    schema = JSON.parse(shell_output("#{bin}/nokv schema"))
    assert_equal "nokv.workbench.mcp_input_schemas.v1", schema.fetch("schema")
    assert_equal 18, schema.fetch("tools").length
  end
end
