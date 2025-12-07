const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const aoc2025 = @import("aoc2025");

const input = @embedFile("input/input.txt");

const Operator = enum {
    Multiply,
    Add,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const part = aoc2025.parse_command_line();
    if (part == .@"2") return error.NotImplemented;

    var operators = try std.ArrayList(Operator).initCapacity(allocator, 1);
    defer operators.clearAndFree(allocator);

    var columns: []u64 = undefined;
    defer allocator.free(columns);

    var lines = mem.splitBackwardsScalar(u8, input, '\n');
    var first_line = true;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var symbols = mem.splitScalar(u8, line, ' ');
        if (first_line) {
            first_line = false;
            while (symbols.next()) |symbol| {
                if (symbol.len == 0) continue;
                const operator: Operator = if (mem.eql(u8, symbol, "*")) Operator.Multiply else if (mem.eql(u8, symbol, "+")) Operator.Add else @panic("unexpected operator");
                try operators.append(allocator, operator);
            }
            columns = try allocator.alloc(u64, operators.items.len);
            for (0..operators.items.len) |i| {
                const operator = operators.items[i];
                columns[i] = switch (operator) {
                    .Multiply => 1,
                    .Add => 0,
                };
            }
        } else {
            var column_index: usize = 0;
            while (symbols.next()) |symbol| {
                if (symbol.len == 0) continue;
                const value = try fmt.parseInt(u64, symbol, 10);
                switch (operators.items[column_index]) {
                    .Add => columns[column_index] += value,
                    .Multiply => columns[column_index] *= value,
                }
                column_index += 1;
            }
        }
    }

    var sum: usize = 0;
    for (columns) |column| sum += column;
    std.debug.print("{any}\n", .{sum});
}
