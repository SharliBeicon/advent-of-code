//! https://adventofcode.com/2024/day/8

const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const sqrt = std.math.sqrt;
const pow = std.math.pow;

const util = @import("util.zig");
const gpa = util.gpa;

const Coords = [2]isize;

const data = @embedFile("data/day08.txt");

pub fn main() !void {
    var it = tokenizeSca(u8, data, '\n');
    var grid_list = List([]const u8).init(gpa);
    defer grid_list.deinit();
    while (it.next()) |line| {
        try grid_list.append(line);
    }
    const grid = try grid_list.toOwnedSlice();

    var antennas = try collectAntennas(grid);
    defer {
        var at_it = antennas.iterator();
        while (at_it.next()) |antenna_group| {
            antenna_group.value_ptr.*.deinit();
        }
        antennas.deinit();
    }

    var antinodes = try getAntinodes(grid, antennas);
    defer antinodes.deinit();
    var antinodes_with_harmonics = try getAntinodesWithHarmonics(grid, antennas);
    defer antinodes_with_harmonics.deinit();

    print("***Day 08***\nPart 01: {}\nPart 02: {}\n\n", .{
        antinodes.count(),
        antinodes_with_harmonics.count(),
    });
}

fn collectAntennas(grid: [][]const u8) !Map(u8, List(Coords)) {
    var antennas = Map(u8, List(Coords)).init(gpa);
    for (grid, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (cell != '.') {
                const antenna_group = try antennas.getOrPut(cell);
                if (!antenna_group.found_existing) {
                    antenna_group.value_ptr.* = List(Coords).init(gpa);
                }
                try antenna_group.value_ptr.*.append(.{
                    @intCast(i),
                    @intCast(j),
                });
            }
        }
    }
    return antennas;
}

fn getAntinodes(grid: [][]const u8, antennas: Map(u8, List(Coords))) !Map(Coords, void) {
    var antinodes = Map(Coords, void).init(gpa);
    var it = antennas.iterator();
    while (it.next()) |antenna_group| {
        for (antenna_group.value_ptr.*.items, 0..) |current_at, i| {
            if (antenna_group.value_ptr.*.items.len > 1) _ = try antinodes.getOrPut(
                Coords{ current_at[0], current_at[1] },
            );
            for (antenna_group.value_ptr.*.items[i + 1 ..]) |target_at| {
                const dx = target_at[0] - current_at[0];
                const dy = target_at[1] - current_at[1];

                const dist = sqrt(@as(f64, (@floatFromInt(pow(isize, dx, 2)))) +
                    @as(f64, (@floatFromInt(pow(isize, dy, 2)))));

                const u_vec: [2]f64 = .{
                    @as(f64, @floatFromInt(dx)) / dist,
                    @as(f64, @floatFromInt(dy)) / dist,
                };

                const delta_x = @round(u_vec[0] * dist);
                const delta_y = @round(u_vec[1] * dist);

                const antinode1 = Coords{
                    current_at[0] - @as(isize, @intFromFloat(delta_x)),
                    current_at[1] - @as(isize, @intFromFloat(delta_y)),
                };

                if (inBounds(grid, antinode1)) {
                    _ = try antinodes.getOrPut(antinode1);
                }

                const antinode2 = Coords{
                    target_at[0] + @as(isize, @intFromFloat(delta_x)),
                    target_at[1] + @as(isize, @intFromFloat(delta_y)),
                };

                if (inBounds(grid, antinode2)) {
                    _ = try antinodes.getOrPut(antinode2);
                }
            }
        }
    }
    return antinodes;
}
fn getAntinodesWithHarmonics(grid: [][]const u8, antennas: Map(u8, List(Coords))) !Map(Coords, void) {
    var antinodes = Map(Coords, void).init(gpa);
    var it = antennas.iterator();
    while (it.next()) |antenna_group| {
        for (antenna_group.value_ptr.*.items, 0..) |current_at, i| {
            if (antenna_group.value_ptr.*.items.len > 1) _ = try antinodes.getOrPut(
                Coords{ current_at[0], current_at[1] },
            );
            for (antenna_group.value_ptr.*.items[i + 1 ..]) |target_at| {
                const dx = target_at[0] - current_at[0];
                const dy = target_at[1] - current_at[1];

                const dist = sqrt(@as(f64, (@floatFromInt(pow(isize, dx, 2)))) +
                    @as(f64, (@floatFromInt(pow(isize, dy, 2)))));

                const u_vec: [2]f64 = .{
                    @as(f64, @floatFromInt(dx)) / dist,
                    @as(f64, @floatFromInt(dy)) / dist,
                };

                const delta_x = @round(u_vec[0] * dist);
                const delta_y = @round(u_vec[1] * dist);

                var antinode1 = Coords{
                    current_at[0] - @as(isize, @intFromFloat(delta_x)),
                    current_at[1] - @as(isize, @intFromFloat(delta_y)),
                };

                while (inBounds(grid, antinode1)) {
                    _ = try antinodes.getOrPut(antinode1);

                    antinode1 = Coords{
                        antinode1[0] - @as(isize, @intFromFloat(delta_x)),
                        antinode1[1] - @as(isize, @intFromFloat(delta_y)),
                    };
                }

                var antinode2 = Coords{
                    target_at[0] + @as(isize, @intFromFloat(delta_x)),
                    target_at[1] + @as(isize, @intFromFloat(delta_y)),
                };

                while (inBounds(grid, antinode2)) {
                    _ = try antinodes.getOrPut(antinode2);

                    antinode2 = Coords{
                        antinode2[0] + @as(isize, @intFromFloat(delta_x)),
                        antinode2[1] + @as(isize, @intFromFloat(delta_y)),
                    };
                }
            }
        }
    }
    return antinodes;
}
fn inBounds(
    grid: [][]const u8,
    pos: Coords,
) bool {
    return (pos[0] >= 0 and
        pos[1] >= 0 and
        pos[0] < @as(isize, @intCast(grid.len)) and
        pos[1] < @as(isize, @intCast(grid[0].len)));
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
