const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const aoc2025 = @import("aoc2025");

const input = @embedFile("input/input.txt");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const part = aoc2025.parse_command_line();
    const batteriesPerBank: usize = switch (part) {
        .@"1" => 2,
        .@"2" => 12,
    };

    var lines = mem.splitScalar(u8, input, '\n');
    var sum: usize = 0;
    while (lines.peek() != null) {
        const line = lines.next().?;
        if (line.len == 0) break;

        var joltageOfLine: usize = 0;

        var digits = try std.ArrayList(u32).initCapacity(allocator, line.len);
        defer digits.clearAndFree(allocator);

        for (line) |char| {
            const digit = try fmt.parseInt(u32, &[_]u8{char}, 10);
            try digits.append(allocator, digit);
        }

        var maxIndex: usize = line.len - batteriesPerBank + 1;
        var minIndex: usize = 0;

        for (0..batteriesPerBank) |digitPosition| {
            const currentSlice = digits.items[minIndex..maxIndex];
            const batteryIndex = std.sort.argMax(u32, currentSlice, {}, std.sort.asc(u32)) orelse @panic("did not find any digit");
            minIndex += batteryIndex + 1;
            maxIndex += 1;
            const digit = currentSlice[batteryIndex];
            const tenPower = batteriesPerBank - digitPosition - 1;
            const joltage = digit * std.math.pow(usize, 10, tenPower);
            joltageOfLine += joltage;
        }

        sum += joltageOfLine;
    }
    std.debug.print("{d}\n", .{sum});
}
