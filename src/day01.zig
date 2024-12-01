const std = @import("std");
const List = std.ArrayList;
const Map = std.AutoHashMap;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var rows = splitSca(u8, data, '\n');
    var left = List([]const u8).init(gpa);
    defer left.deinit();
    var right = List([]const u8).init(gpa);
    defer right.deinit();
    var right_score = Map(i32, u32).init(gpa);
    defer right_score.deinit();

    while (rows.next()) |row| {
        var sides = splitSeq(u8, row, "   ");

        try left.append(sides.next() orelse break);
        try right.append(sides.next() orelse break);
    }
    _ = left.pop(); // ESC byte out

    sort([]const u8, left.items, {}, lessThan);
    sort([]const u8, right.items, {}, lessThan);

    var distance: u32 = 0;
    for (left.items, right.items) |l, r| {
        const ileft = try parseInt(i32, l, 10);
        const iright = try parseInt(i32, r, 10);
        distance += @abs(ileft - iright);

        const result = try right_score.getOrPut(iright);
        if (!result.found_existing) {
            result.value_ptr.* = 1;
        } else {
            result.value_ptr.* += 1;
        }
    }

    var similarity: u32 = 0;
    for (left.items) |item| {
        const value = try parseInt(i32, item, 10);
        const result = right_score.get(value) orelse continue;
        similarity += @as(u32, @intCast(value)) * result;
    }

    print("Total Distance: {}\n", .{distance});
    print("Similarity Score: {}\n", .{similarity});
}

fn lessThan(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.lessThan(u8, a, b);
}

const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const sort = std.sort.block;
