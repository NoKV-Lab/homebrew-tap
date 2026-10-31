# Copyright 2024-2026 The NoKV Authors.
# SPDX-License-Identifier: Apache-2.0

class Nokv < Formula
  desc "Metadata control plane and Workbench CLI for agent workspaces"
  homepage "https://nokv.io/"
  url "https://github.com/NoKV-Lab/NoKV/releases/download/v0.20.0/nokv-0.20.0-source.tar.gz"
  sha256 "b4f8be1d877c9107a6d3e4da57bd1319d023a11b75a30dad33210b5028c875af"
  license "Apache-2.0"
  version_scheme 1

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  def install
    ENV["NOKV_BUILD_GIT_COMMIT"] = "6e8a84e43d1617c8366c0424ffc8898e52573db7"
    ENV["NOKV_BUILD_CARGO_LOCK_SHA256"] = "e0d81ed24a7453bfacaf487fb2cc75ce9a428c734fa6618c28ffac3fe0d9032c"
    ENV["NOKV_BUILD_HOLT_VERSION"] = "0.8.8"
    ENV["NOKV_BUILD_HOLT_SOURCE"] = "registry+https://github.com/rust-lang/crates.io-index"
    ENV["NOKV_BUILD_HOLT_CHECKSUM"] = "2ebadadf8981b49ae2ffcac930f26d10c5a76a0db127c9b7eabacea8282976d1"

    system "cargo", "install", *std_cargo_args(path: "crates/nokv")
  end

  test do
    assert_equal "nokv 0.20.0", shell_output("#{bin}/nokv --version").strip

    identity = JSON.parse(shell_output("#{bin}/nokv version --json"))
    assert_equal "0.20.0", identity.fetch("version")
    assert_equal "6e8a84e43d1617c8366c0424ffc8898e52573db7", identity.fetch("git_commit")
    assert_equal "e0d81ed24a7453bfacaf487fb2cc75ce9a428c734fa6618c28ffac3fe0d9032c",
                 identity.fetch("cargo_lock_sha256")
    assert_equal "0.8.8", identity.dig("holt", "version")
    assert_equal "registry+https://github.com/rust-lang/crates.io-index", identity.dig("holt", "source")
    assert_equal "2ebadadf8981b49ae2ffcac930f26d10c5a76a0db127c9b7eabacea8282976d1", identity.dig("holt", "checksum")
    assert_equal "nokv.workbench.mcp_input_schemas.v1", identity.fetch("workbench_contract_schema")
    assert_equal 18, identity.fetch("workbench_tool_count")

    schema = JSON.parse(shell_output("#{bin}/nokv schema"))
    assert_equal "nokv.workbench.mcp_input_schemas.v1", schema.fetch("schema")
    assert_equal 18, schema.fetch("tools").length
  end
end
