# Copyright 2024-2026 The NoKV Authors.
# SPDX-License-Identifier: Apache-2.0

class Nokv < Formula
  desc "Metadata control plane and Workbench MCP server for agent workspaces"
  homepage "https://nokv.io/"
  url "https://github.com/NoKV-Lab/NoKV/releases/download/v0.12.0/nokv-0.12.0-source.tar.gz"
  sha256 "d3b1b61f64ddd8fbd79efc4b6a8d1c1b1419d57e471fb9aefd3667123fddc7c2"
  license "Apache-2.0"
  version_scheme 1

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  def install
    ENV["NOKV_BUILD_GIT_COMMIT"] = "303316208f95b89b6e2854d542ef72e566e60dfc"
    ENV["NOKV_BUILD_CARGO_LOCK_SHA256"] = "63bc25b25a979237442cd718cb7d30102398984d40ec6e0b1c57a2f31005ae73"
    ENV["NOKV_BUILD_HOLT_VERSION"] = "0.8.7"
    ENV["NOKV_BUILD_HOLT_SOURCE"] = "registry+https://github.com/rust-lang/crates.io-index"
    ENV["NOKV_BUILD_HOLT_CHECKSUM"] = "c0429a061efcfb85c11a21a62eaf20a2410e014ca6cc5a987b5a8c59e3984463"

    system "cargo", "install", *std_cargo_args(path: "crates/nokv")
  end

  test do
    assert_equal "nokv 0.12.0", shell_output("#{bin}/nokv --version").strip

    identity = JSON.parse(shell_output("#{bin}/nokv version --json"))
    assert_equal "0.12.0", identity.fetch("version")
    assert_equal "303316208f95b89b6e2854d542ef72e566e60dfc", identity.fetch("git_commit")
    assert_equal "63bc25b25a979237442cd718cb7d30102398984d40ec6e0b1c57a2f31005ae73",
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
