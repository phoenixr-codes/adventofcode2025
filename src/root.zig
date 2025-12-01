//! Central library

const std = @import("std");
const fmt = std.fmt;
const process = std.process;

pub const Part = enum { @"1", @"2" };

pub fn parse_command_line() Part {
    var args = process.args();
    if (!args.skip()) unreachable;
    return switch (fmt.parseInt(u2, args.next() orelse @panic("Missing argument `part`"), 10) catch @panic("Failed to parse argument `part`")) {
        1 => .@"1",
        2 => .@"2",
        else => @panic("Invalid part"),
    };
}
