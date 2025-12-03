const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{.preferred_optimize_mode = .Debug});
    const mod = b.addModule("adventofcode2025", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const days = [_][]const u8{"day01", "day02", "day03"};
    inline for (days) |day| {
        const exe = b.addExecutable(.{
            .name = "adventofcode2025-" ++ day,
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/" ++ day ++ "/main.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "aoc2025", .module = mod },
                },
            }),
        });
        b.installArtifact(exe);

        const run_step = b.step("run-" ++ day, "Run " ++ day);

        const run_cmd = b.addRunArtifact(exe);
        run_step.dependOn(&run_cmd.step);

        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }
}
