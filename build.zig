const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "raylib-helloworld",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    //note that the name here in the string needs to match whatever you used
    //in build.zig.zon
    //This is a reference to the dependency.
    //When building, the dependency will be extracted in ~/.cache/zig/p/<hash>
    //You can then refer to paths in the dependency with
    //raylibDep.path()
    //the the build artifact with
    //raylibDep.artifact()

    const raylibDep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    //this artifact name also needs to match the dependency name used in
    //build.zig.zon
    exe.linkLibrary(raylibDep.artifact("raylib"));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
