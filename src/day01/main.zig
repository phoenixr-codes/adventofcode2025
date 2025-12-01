const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const aoc2025 = @import("aoc2025");

const input = @embedFile("input/input.txt");

const RotationInstruction = struct { direction: enum { left, right }, amount: u32 };

const Cycle = struct {
    dial: u8,
    min: u8,
    max: u8,

    pub fn left(self: *Cycle) void {
        if (self.dial == self.min) {
            self.dial = self.max;
            return;
        }
        self.dial -= 1;
    }

    pub fn right(self: *Cycle) void {
        if (self.dial == self.max) {
            self.dial = self.min;
            return;
        }
        self.dial += 1;
    }
};

fn parse_line(line: []const u8) !RotationInstruction {
    const direction = line[0];
    const digits = line[1..];
    const amount = try fmt.parseInt(u32, digits, 10);
    return .{
        .amount = amount,
        .direction = if (direction == 'L') .left else if (direction == 'R') .right else return error.NotANumber,
    };
}

pub fn main() !void {
    const part: aoc2025.Part = aoc2025.parse_command_line();
    var lines = mem.splitScalar(u8, input, '\n');
    var cycle = Cycle{
        .dial = 50,
        .min = 0,
        .max = 99,
    };
    var zeroes: u32 = 0;
    while (lines.peek() != null) {
        const line = lines.next().?;
        if (line.len == 0) break;
        const instruction = try parse_line(line);
        switch (instruction.direction) {
            .left => for (0..instruction.amount) |_| {
                cycle.left();
                if (part == .@"2" and cycle.dial == 0) zeroes += 1;
            },
            .right => for (0..instruction.amount) |_| {
                cycle.right();
                if (part == .@"2" and cycle.dial == 0) zeroes += 1;
            },
        }
        if (part == .@"1" and cycle.dial == 0) zeroes += 1;
    }
    std.debug.print("{any}\n", .{zeroes});
}
