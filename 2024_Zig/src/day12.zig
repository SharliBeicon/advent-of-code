const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;

const util = @import("util.zig");
const gpa = util.gpa;

const tokenizeSca = std.mem.tokenizeScalar;
const print = std.debug.print;
const contains = std.mem.containsAtLeast;

const data = @embedFile("data/day12.txt");

const Position = @Vector(2, isize);

const steps = [_]Position{
    .{ -1, 0 }, // UP
    .{ 0, 1 }, // RIGHT
    .{ 1, 0 }, // DOWN
    .{ 0, -1 }, // LEFT
};

const GardenPlot = struct {
    kind: u8,
    items: []Position,
};

pub fn main() !void {
    var it = tokenizeSca(u8, data, '\n');
    var farm_list = List([]const u8).init(gpa);
    while (it.next()) |item| {
        try farm_list.append(item);
    }
    const farm = try farm_list.toOwnedSlice();

    var visited: [][]bool = try Allocator.alloc(gpa, []bool, farm.len);
    var id: usize = 0;
    while (id < farm.len) : (id += 1) {
        visited[id] = try Allocator.alloc(gpa, bool, farm[0].len);
        @memset(visited[id], false);
    }

    const garden_plots: []GardenPlot = try computeGardenPlots(farm, &visited);

    var result01: u64 = 0;
    var result02: u64 = 0;
    for (garden_plots) |plot| {
        result01 += plot.items.len * try calculatePerimeter(plot.items);
        result02 += plot.items.len * try countSides(plot.items);
    }

    print("***Day 12***\nPart 01: {}\nPart 02: {}\n\n", .{ result01, result02 });
}

fn computeGardenPlots(farm: [][]const u8, visited: *[][]bool) ![]GardenPlot {
    var garden_plots = List(GardenPlot).init(gpa);

    for (farm, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (!visited.*[i][j]) {
                var positions = List(Position).init(gpa);
                try computeSinglePlot(farm, visited, .{ @intCast(i), @intCast(j) }, &positions);
                const garden_plot = GardenPlot{
                    .kind = cell,
                    .items = try positions.toOwnedSlice(),
                };

                try garden_plots.append(garden_plot);
            }
        }
    }

    return try garden_plots.toOwnedSlice();
}

fn computeSinglePlot(
    farm: [][]const u8,
    visited: *[][]bool,
    current_pos: Position,
    positions: *List(Position),
) !void {
    try positions.append(current_pos);
    visited.*[@intCast(current_pos[0])][@intCast(current_pos[1])] = true;

    for (steps) |step| {
        const next_pos: Position = current_pos + step;
        if (util.inBounds(farm, next_pos) and
            !visited.*[@intCast(next_pos[0])][@intCast(next_pos[1])] and
            farm[@intCast(next_pos[0])][@intCast(next_pos[1])] ==
            farm[@intCast(current_pos[0])][@intCast(current_pos[1])])
        {
            try computeSinglePlot(farm, visited, next_pos, positions);
        }
    }
}

fn calculatePerimeter(positions: []Position) !u64 {
    var perimeter: usize = 0;
    var positionSet = Map(Position, void).init(gpa);
    defer positionSet.deinit();

    for (positions) |pos| {
        _ = try positionSet.getOrPut(pos);
    }

    for (positions) |pos| {
        for (steps) |step| {
            const neighbor = pos + step;
            if (!positionSet.contains(neighbor)) {
                perimeter += 1;
            }
        }
    }

    return perimeter;
}

fn countSides(positions: []Position) !u32 {
    var sides: u32 = 0;
    var positionSet = Map(Position, void).init(gpa);
    defer positionSet.deinit();

    for (positions) |pos| {
        _ = try positionSet.getOrPut(pos);
    }

    for (positions) |pos| {
        // Outer corners
        if (!positionSet.contains(.{ pos[0] - 1, pos[1] }) and
            !positionSet.contains(.{ pos[0], pos[1] - 1 })) sides += 1;
        if (!positionSet.contains(.{ pos[0] + 1, pos[1] }) and
            !positionSet.contains(.{ pos[0], pos[1] - 1 })) sides += 1;
        if (!positionSet.contains(.{ pos[0] - 1, pos[1] }) and
            !positionSet.contains(.{ pos[0], pos[1] + 1 })) sides += 1;
        if (!positionSet.contains(.{ pos[0] + 1, pos[1] }) and
            !positionSet.contains(.{ pos[0], pos[1] + 1 })) sides += 1;

        // Inner corners
        if (positionSet.contains(.{ pos[0] - 1, pos[1] }) and
            positionSet.contains(.{ pos[0], pos[1] - 1 }) and
            !positionSet.contains(.{ pos[0] - 1, pos[1] - 1 })) sides += 1;
        if (positionSet.contains(.{ pos[0] + 1, pos[1] }) and
            positionSet.contains(.{ pos[0], pos[1] - 1 }) and
            !positionSet.contains(.{ pos[0] + 1, pos[1] - 1 })) sides += 1;
        if (positionSet.contains(.{ pos[0] - 1, pos[1] }) and
            positionSet.contains(.{ pos[0], pos[1] + 1 }) and
            !positionSet.contains(.{ pos[0] - 1, pos[1] + 1 })) sides += 1;
        if (positionSet.contains(.{ pos[0] + 1, pos[1] }) and
            positionSet.contains(.{ pos[0], pos[1] + 1 }) and
            !positionSet.contains(.{ pos[0] + 1, pos[1] + 1 })) sides += 1;
    }

    return sides;
}
