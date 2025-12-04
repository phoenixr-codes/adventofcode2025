const std = @import("std");
const mem = std.mem;
const aoc2025 = @import("aoc2025");

const input = @embedFile("input/input.txt");

fn is_paper_roll(cell: u8) bool {
    return cell == '@';
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const part = aoc2025.parse_command_line();

    var lines = mem.splitScalar(u8, input, '\n');

    const rows = mem.count(u8, input, &[_]u8{'\n'});
    const cols = lines.peek().?.len;

    const grid: [][]u8 = try allocator.alloc([]u8, rows);
    defer allocator.free(grid);
    const next_grid: [][]u8 = try allocator.alloc([]u8, rows);
    defer allocator.free(next_grid);

    for (0..rows) |i| {
        const line = lines.next() orelse @panic("expected one more line");
        grid[i] = @constCast(line);
    }

    if (part == .@"2") @memcpy(next_grid, grid);

    var accessable_rolls: usize = 0;
    var total_accessable_rolls: usize = 0;
    var initial = true;
    while (initial or (part == .@"2" and accessable_rolls > 0)) : (initial = false) {
        accessable_rolls = 0;
        for (0..rows) |row| {
            for (0..cols) |col| {
                const cell = grid[row][col];
                if (!is_paper_roll(cell)) continue;
                var adjacent_paper_roll_cells: usize = 0;
                const directions = [3]isize{ 0, 1, -1 };
                for (directions) |row_direction| {
                    for (directions) |col_direction| {
                        if (row_direction == 0 and col_direction == 0) continue;
                        const adjacent_cell_row = @as(isize, @intCast(row)) + row_direction;
                        const adjacent_cell_col = @as(isize, @intCast(col)) + col_direction;
                        if (adjacent_cell_row < 0 or adjacent_cell_row >= rows) continue;
                        if (adjacent_cell_col < 0 or adjacent_cell_col >= cols) continue;
                        const adjacent_cell = grid[@intCast(adjacent_cell_row)][@intCast(adjacent_cell_col)];
                        if (is_paper_roll(adjacent_cell)) adjacent_paper_roll_cells += 1;
                    }
                }
                if (adjacent_paper_roll_cells < 4) {
                    accessable_rolls += 1;
                    if (part == .@"2") next_grid[row][col] = 'x';
                }
            }
        }
        if (part == .@"2") {
            @memcpy(grid, next_grid);
        }
        total_accessable_rolls += accessable_rolls;
    }

    std.debug.print("{d}", .{total_accessable_rolls});
}
