const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var rows = splitSca(u8, data, '\n');
    var left = std.ArrayList([]const u8).init(gpa);
    defer left.deinit();
    var right = std.ArrayList([]const u8).init(gpa);
    defer right.deinit();
    var right_score = std.AutoHashMap(i32, u32).init(gpa);
    defer right_score.deinit();
    // >>> PART 1 >>>
    while (rows.next()) |row| {
        var sides = splitSeq(u8, row, "   ");

        try left.append(sides.next() orelse break);
        try right.append(sides.next() orelse break);
    }
    sort([]const u8, left.items, {}, lessThan);
    sort([]const u8, right.items, {}, lessThan);

    var distance: u32 = 0;
    for (left.items, right.items) |l, r| {
        distance += @abs(try std.fmt.parseInt(i32, l, 10) - try std.fmt.parseInt(i32, r, 10));
    }

    std.debug.print("Total Distance: {}\n", .{distance});
    // <<< PART 1 <<<

    // >>> PART 2 >>>
    for (right.items) |item| {
        const value = try std.fmt.parseInt(i32, item, 10);
        const result = try right_score.getOrPut(value);
        if (!result.found_existing) {
            result.value_ptr.* = 1;
        } else {
            result.value_ptr.* += 1;
        }
    }

    var similarity: u32 = 0;
    for (left.items) |item| {
        const value = try std.fmt.parseInt(i32, item, 10);
        const result = right_score.get(value) orelse continue;
        similarity += @as(u32, @intCast(value)) * result;
    }

    std.debug.print("Similarity Score: {}\n", .{similarity});
    // <<< PART 2 <<<
}

fn lessThan(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.lessThan(u8, a, b);
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
