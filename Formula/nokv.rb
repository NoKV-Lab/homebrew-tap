# Copyright 2024-2026 The NoKV Authors.
# SPDX-License-Identifier: Apache-2.0

class Nokv < Formula
  desc "Metadata control plane and Workbench MCP server for agent workspaces"
  homepage "https://nokv.io/"
  url "https://github.com/NoKV-Lab/NoKV/releases/download/v0.10.0/nokv-0.10.0-source.tar.gz"
  sha256 "4b486c18bd4c6c0d07e3a55834bf50bb97cc6085c46bdd405101530ad89ad4c1"
  license "Apache-2.0"
  version_scheme 1

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  def install
    ENV["NOKV_BUILD_GIT_COMMIT"] = "2dd5b53f8bbc80bee673a12f58345a1129c2cb1e"
    ENV["NOKV_BUILD_CARGO_LOCK_SHA256"] = "3e5533296125a44aeea0854b6a0ebadf95402ab2790a15341c45fa62ec7a63d8"
    ENV["NOKV_BUILD_HOLT_VERSION"] = "0.8.5"
    ENV["NOKV_BUILD_HOLT_SOURCE"] = "registry+https://github.com/rust-lang/crates.io-index"
    ENV["NOKV_BUILD_HOLT_CHECKSUM"] = "de964ee5f86d1ffba48f3213c97754bf80ea4289d5084419a4385a687c6818a4"

    system "cargo", "install", *std_cargo_args(path: "crates/nokv")
  end

  test do
    assert_equal "nokv 0.10.0", shell_output("#{bin}/nokv --version").strip

    identity = JSON.parse(shell_output("#{bin}/nokv version --json"))
    assert_equal "0.10.0", identity.fetch("version")
    assert_equal "2dd5b53f8bbc80bee673a12f58345a1129c2cb1e", identity.fetch("git_commit")
    assert_equal "3e5533296125a44aeea0854b6a0ebadf95402ab2790a15341c45fa62ec7a63d8",
                 identity.fetch("cargo_lock_sha256")
    assert_equal "0.8.5", identity.dig("holt", "version")
    assert_equal "registry+https://github.com/rust-lang/crates.io-index", identity.dig("holt", "source")
    assert_equal "de964ee5f86d1ffba48f3213c97754bf80ea4289d5084419a4385a687c6818a4", identity.dig("holt", "checksum")
    assert_equal "nokv.workbench.mcp_input_schemas.v1", identity.fetch("workbench_contract_schema")
    assert_equal 18, identity.fetch("workbench_tool_count")

    schema = JSON.parse(shell_output("#{bin}/nokv schema"))
    assert_equal "nokv.workbench.mcp_input_schemas.v1", schema.fetch("schema")
    assert_equal 18, schema.fetch("tools").length
  end
end
