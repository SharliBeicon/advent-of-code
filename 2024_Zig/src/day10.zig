const std = @import("std");
const List = std.ArrayList;

const util = @import("util.zig");
const gpa = util.gpa;

const tokenizeSca = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const data = @embedFile("data/day10.txt");

const step_direction = [_]@Vector(2, isize){
    .{ -1, 0 }, // UP
    .{ 0, 1 }, // RIGHT
    .{ 1, 0 }, // DOWN
    .{ 0, -1 }, // LEFT
};

pub fn main() !void {
    var map_list = List([]const u8).init(gpa);
    var trailheads_list = List(@Vector(2, isize)).init(gpa);
    var visited_grid = List([]bool).init(gpa);
    var it = tokenizeSca(u8, data, '\n');
    var i: isize = 0;

    while (it.next()) |row| {
        try map_list.append(row);
        var visited_list = List(bool).init(gpa);

        for (row, 0..) |item, j| {
            if (item == '0') {
                try trailheads_list.append(.{ i, @intCast(j) });
            }
            try visited_list.append(false);
        }
        try visited_grid.append(try visited_list.toOwnedSlice());
        i += 1;
    }
    const map01 = try map_list.toOwnedSlice();
    const map02 = try std.mem.Allocator.dupe(gpa, []const u8, map01);
    for (map01, 0..) |row, mi| {
        map02[mi] = try std.mem.Allocator.dupe(gpa, u8, row);
    }

    map_list.deinit();
    const trailheads = try trailheads_list.toOwnedSlice();
    trailheads_list.deinit();
    var visited = try visited_grid.toOwnedSlice();
    visited_grid.deinit();

    var part01: u32 = 0;
    var part02: u32 = 0;
    for (trailheads) |th| {
        for (visited) |row| {
            @memset(row, false);
        }
        part01 += try getTrailsPart01(map01, th, 0, &visited);
    }
    for (trailheads) |th| {
        for (visited) |row| {
            @memset(row, false);
        }
        part02 += try getTrailsPart02(map02, th, 0, &visited);
    }

    std.debug.print("***DAY 10***\nPart 01: {}\nPart 02: {}\n\n", .{ part01, part02 });
}

fn getTrailsPart01(map: [][]const u8, trailhead: @Vector(2, isize), next_expected: isize, visited: *[][]bool) !u32 {
    if (!util.inBounds(map, trailhead)) return 0;

    const current = try parseInt(
        isize,
        &[_]u8{map[@intCast(trailhead[0])][@intCast(trailhead[1])]},
        10,
    );

    if (visited.*[@intCast(trailhead[0])][@intCast(trailhead[1])] or
        current != next_expected)
        return 0;

    visited.*[@intCast(trailhead[0])][@intCast(trailhead[1])] = true;
    if (current == 9) return 1;

    var trails: u32 = 0;
    for (step_direction) |step| {
        const next_step = trailhead + step;

        trails += try getTrailsPart01(map, next_step, current + 1, visited);
    }

    visited.*[@intCast(trailhead[0])][@intCast(trailhead[1])] = false;
    return trails;
}

fn getTrailsPart02(map: [][]const u8, trailhead: @Vector(2, isize), next_expected: isize, visited: *[][]bool) !u32 {
    if (!util.inBounds(map, trailhead)) return 0;

    const current = try parseInt(
        isize,
        &[_]u8{map[@intCast(trailhead[0])][@intCast(trailhead[1])]},
        10,
    );

    if (visited.*[@intCast(trailhead[0])][@intCast(trailhead[1])] or
        current != next_expected)
        return 0;

    if (current == 9) return 1;

    var trails: u32 = 0;
    for (step_direction) |step| {
        const next_step = trailhead + step;

        trails += try getTrailsPart02(map, next_step, current + 1, visited);
    }

    visited.*[@intCast(trailhead[0])][@intCast(trailhead[1])] = false;
    return trails;
}
