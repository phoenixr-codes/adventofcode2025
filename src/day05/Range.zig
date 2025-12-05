const testing = @import("std").testing;

start: usize,
end: usize,

pub fn init(start: usize, end: usize) @This() {
    if (start > end) @panic("start of range must not be greater than end");
    return .{
        .start = start,
        .end = end,
    };
}

pub fn contains(self: @This(), number: usize) bool {
    return self.start <= number and self.end >= number;
}

/// Returns two ranges merged if they overlap.
///
/// Examples of overlapping ranges:
///
/// ```
/// ####
///    ####
/// ```
///
/// ```
///    ####
/// ####
/// ```
///
/// ```
/// ######
///  ####
/// ```
///
/// ```
///  ####
/// ######
/// ```
pub fn merged(self: @This(), other: @This()) ?@This() {
    const overlaps = other.start <= self.end and self.start <= other.end;
    if (overlaps) {
        return .{
            .start = @min(self.start, other.start),
            .end = @max(self.end, other.end),
        };
    }
    return null;
}

test "overlap left" {
    const range = init(0, 3).merged(init(2, 4));
    try testing.expect(range.?.start == 0);
    try testing.expect(range.?.end == 4);
}

test "overlap right" {
    const range = init(2, 4).merged(init(0, 3));
    try testing.expect(range.?.start == 0);
    try testing.expect(range.?.end == 4);
}

test "overlap subrange" {
    const range = init(0, 20).merged(init(5, 15));
    try testing.expect(range.?.start == 0);
    try testing.expect(range.?.end == 20);
}

test "overlap superrange" {
    const range = init(5, 15).merged(init(0, 20));
    try testing.expect(range.?.start == 0);
    try testing.expect(range.?.end == 20);
}

test "no overlap left" {
    const range = init(3, 10).merged(init(12, 20));
    try testing.expect(range == null);
}

test "no overlap right" {
    const range = init(12, 20).merged(init(3, 10));
    try testing.expect(range == null);
}
