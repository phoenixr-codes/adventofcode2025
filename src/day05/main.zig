const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const Range = @import("Range.zig");
const aoc2025 = @import("aoc2025");

const input = @embedFile("input/input.txt");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const part = aoc2025.parse_command_line();

    const ingredientDataSeparator = "\n\n";
    const ingredientDataSplit = mem.indexOf(u8, input, ingredientDataSeparator) orelse @panic("invalid format");
    var lines_fresh_ingredient_ids = mem.splitScalar(u8, input[0..ingredientDataSplit], '\n');
    var lines_available_ingredient_ids = mem.splitScalar(u8, input[ingredientDataSplit + ingredientDataSeparator.len ..], '\n');
    var fresh_ingredient_ranges = try std.ArrayList(Range).initCapacity(allocator, lines_fresh_ingredient_ids.buffer.len);
    defer fresh_ingredient_ranges.clearAndFree(allocator);

    while (lines_fresh_ingredient_ids.peek() != null) {
        const line_fresh_ingredients = lines_fresh_ingredient_ids.next() orelse unreachable;
        const range_separator_index = mem.indexOfScalar(u8, line_fresh_ingredients, '-') orelse @panic("missing range separator");
        const range_start = try fmt.parseInt(usize, line_fresh_ingredients[0..range_separator_index], 10);
        const range_end = try fmt.parseInt(usize, line_fresh_ingredients[range_separator_index + 1 ..], 10);
        const range: Range = .{ .start = range_start, .end = range_end };
        const insertIndex = for (0..fresh_ingredient_ranges.items.len) |i| {
            if (fresh_ingredient_ranges.items[i].start > range.start) break i;
        } else fresh_ingredient_ranges.items.len;
        try fresh_ingredient_ranges.insert(allocator, insertIndex, range);

        var i: usize = 0;
        while (i < fresh_ingredient_ranges.items.len) : (i += 1) {
            var current_merged_range = fresh_ingredient_ranges.items[i];
            var j: usize = 0;
            while (i + j < fresh_ingredient_ranges.items.len) : (j += 1) {
                current_merged_range = current_merged_range.merged(fresh_ingredient_ranges.items[i + j]) orelse break;
            }
            try fresh_ingredient_ranges.replaceRange(allocator, i, j, &[1]Range{current_merged_range});
        }
    }

    switch (part) {
        .@"1" => {
            var fresh_ingredients: usize = 0;
            ingredients: while (lines_available_ingredient_ids.peek() != null) {
                const line_available_ingredients = lines_available_ingredient_ids.next() orelse unreachable;
                if (line_available_ingredients.len == 0) break;
                const available_ingredient_id = try fmt.parseInt(usize, line_available_ingredients, 10);
                for (fresh_ingredient_ranges.items) |range| {
                    const is_fresh = range.contains(available_ingredient_id);
                    if (is_fresh) {
                        fresh_ingredients += 1;
                        continue :ingredients;
                    }
                }
            }
            std.debug.print("{d}\n", .{fresh_ingredients});
        },
        .@"2" => {
            var possible_ingredient_ids: usize = 0;
            for (fresh_ingredient_ranges.items) |range| {
                possible_ingredient_ids += range.end - range.start + 1;
            }
            std.debug.print("{d}\n", .{possible_ingredient_ids});
        },
    }
}
