# Copyright 2024-2026 The NoKV Authors.
# SPDX-License-Identifier: Apache-2.0

class Nokv < Formula
  desc "Metadata control plane and Workbench MCP server for agent workspaces"
  homepage "https://nokv.io/"
  url "https://github.com/NoKV-Lab/NoKV/releases/download/v1.0.0/nokv-1.0.0-source.tar.gz"
  sha256 "65d0d3e4587994a98ed200c5359d49f04f3e59cb54f0d0b81bf27a9f4a581e0c"
  license "Apache-2.0"

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  def install
    ENV["NOKV_BUILD_GIT_COMMIT"] = "c41cf4a6a5e29d093020feb85f4d62fcd18d6bb5"
    ENV["NOKV_BUILD_CARGO_LOCK_SHA256"] = "e4520ea348b2089fbc1bbf25e5b7677d0c28a7e678441b81682f47d44f9ed301"
    ENV["NOKV_BUILD_HOLT_VERSION"] = "0.8.4"
    ENV["NOKV_BUILD_HOLT_SOURCE"] = "registry+https://github.com/rust-lang/crates.io-index"
    ENV["NOKV_BUILD_HOLT_CHECKSUM"] = "c0e62dad7ce341d1e1995cc0034cb347d0e562e444b2354f8418410e2ba770e4"

    system "cargo", "install", *std_cargo_args(path: "crates/nokv")
  end

  test do
    assert_equal "nokv 1.0.0", shell_output("#{bin}/nokv --version").strip

    identity = JSON.parse(shell_output("#{bin}/nokv version --json"))
    assert_equal "1.0.0", identity.fetch("version")
    assert_equal "c41cf4a6a5e29d093020feb85f4d62fcd18d6bb5", identity.fetch("git_commit")
    assert_equal "e4520ea348b2089fbc1bbf25e5b7677d0c28a7e678441b81682f47d44f9ed301",
                 identity.fetch("cargo_lock_sha256")
    assert_equal "0.8.4", identity.dig("holt", "version")
    assert_equal "registry+https://github.com/rust-lang/crates.io-index", identity.dig("holt", "source")
    assert_equal "c0e62dad7ce341d1e1995cc0034cb347d0e562e444b2354f8418410e2ba770e4", identity.dig("holt", "checksum")
    assert_equal "nokv.workbench.mcp_input_schemas.v1", identity.fetch("workbench_contract_schema")
    assert_equal 18, identity.fetch("workbench_tool_count")

    schema = JSON.parse(shell_output("#{bin}/nokv schema"))
    assert_equal "nokv.workbench.mcp_input_schemas.v1", schema.fetch("schema")
    assert_equal 18, schema.fetch("tools").length
  end
end
