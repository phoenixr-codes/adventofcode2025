const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const aoc2025 = @import("aoc2025");

const input = @embedFile("input/input.txt");

/// Returns whether an integer consists of a sequence of digits repeated twice.
fn is_twin_number(num: u64) bool {
    const allocator = std.heap.page_allocator;
    const string = fmt.allocPrint(allocator, "{d}", .{num}) catch @panic("OOM");
    defer allocator.free(string);
    const half = string.len / 2;
    return mem.eql(u8, string[0..half], string[half..]);
}

/// Returns whether an integer consists of a sequence of digits repeated at
/// least twice.
fn is_n_twin_number(num: u64) bool {
    const allocator = std.heap.page_allocator;
    const string = fmt.allocPrint(allocator, "{d}", .{num}) catch @panic("OOM");
    defer allocator.free(string);
    cuts: for (2..string.len + 1) |cuts| {
        if (@mod(string.len, cuts) != 0) continue;
        const width_per_slice = string.len / cuts;
        for (0..width_per_slice) |pointer| {
            var char: ?u8 = null;
            for (0..cuts) |i| {
                const offset = pointer + width_per_slice * i;
                if (char == null) {
                    char = string[offset];
                } else if (char != string[offset]) {
                    continue :cuts;
                }
            }
        }
        return true;
    }
    return false;
}

pub fn main() !void {
    const part: aoc2025.Part = aoc2025.parse_command_line();
    var sum: u64 = 0;
    var ranges = mem.splitScalar(u8, input, ',');
    while (ranges.peek() != null) {
        const range = std.mem.trim(u8, ranges.next().?, "\n");
        const separatorIndex = mem.indexOfScalar(u8, range, '-').?;
        const lower = try fmt.parseInt(u64, range[0..separatorIndex], 10);
        const upper = try fmt.parseInt(u64, range[separatorIndex + 1 ..], 10);
        for (lower..upper + 1) |num| {
            if (part == .@"1" and is_twin_number(num)) sum += num;
            if (part == .@"2" and is_n_twin_number(num)) sum += num;
        }
    }
    std.debug.print("Sum: {d}\n", .{sum});
}
