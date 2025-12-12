const std = @import("std");
const mem = std.mem;
const aoc2025 = @import("aoc2025");

const input = @embedFile("input/input.txt");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const part = aoc2025.parse_command_line();
    if (part == .@"2") return error.NotImplemented;

    var lines = mem.splitScalar(u8, input, '\n');

    var beams = try std.ArrayList(usize).initCapacity(allocator, 1);
    defer beams.clearAndFree(allocator);

    const first_line = lines.first();
    const start_column = mem.indexOfScalar(u8, first_line, 'S') orelse @panic("missing start index");

    try beams.append(allocator, start_column);

    var splits: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var splitters = try std.ArrayList(usize).initCapacity(allocator, 0);
        defer splitters.clearAndFree(allocator);
        var splitter_index: usize = 0;
        while (true) {
            splitter_index = mem.indexOfScalarPos(u8, line, splitter_index + 1, '^') orelse break;
            try splitters.append(allocator, splitter_index);
        }

        var i: usize = 0;
        while (i < beams.items.len) : (i += 1) {
            const beam = beams.items[i];
            for (splitters.items) |splitter| {
                if (beam == splitter) {
                    const left_beam = splitter - 1;
                    const right_beam = splitter + 1;
                    _ = beams.orderedRemove(i);
                    if (mem.indexOfScalar(usize, beams.items, left_beam) == null) {
                        try beams.insert(allocator, i, left_beam);
                        i += 1;
                    }
                    if (mem.indexOfScalar(usize, beams.items, right_beam) == null) {
                        try beams.insert(allocator, i, right_beam);
                        i += 1;
                    }
                    i -= 1;
                    splits += 1;
                }
            }
        }
    }

    std.debug.print("{d}\n", .{splits});
}
