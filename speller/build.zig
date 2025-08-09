const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "speller",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const build_steps = .{
        .run = b.step("run", "Run speller on a single file"),
        .batch = b.step("batch", "Run speller on all data/texts file"),
    };

    const run_exe = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_exe.addArgs(args);
    }
    build_steps.run.dependOn(&run_exe.step);

    const script_file = b.addWriteFiles().add("batch.sh", 
        \\#!/bin/bash
        \\for file in data/texts/*.txt; do
        \\    echo "Processing: $file"
        \\    ./zig-out/bin/speller "$file" > "outputs/$(basename "$file")"
        \\done
    );

    const run_batch = b.addSystemCommand(&.{"bash"});
    run_batch.addFileArg(script_file);

    run_batch.step.dependOn(&exe.step);
    build_steps.batch.dependOn(&run_batch.step);
}
