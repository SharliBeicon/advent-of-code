const std = @import("std");
const List = std.ArrayList;

const indexOf = std.mem.indexOfScalar;
const eql = std.mem.eql;
const print = std.debug.print;
const tokenizeSca = std.mem.tokenizeScalar;
const contains = std.mem.containsAtLeast;

const util = @import("util.zig");
const gpa = util.gpa;

const Step = [2]isize;
const Coords = [2]isize;

const step_direction = [_]Step{
    .{ -1, 0 }, // UP
    .{ 0, 1 }, // RIGHT
    .{ 1, 0 }, // DOWN
    .{ 0, -1 }, // LEFT
};
const guard_direction = [_]u8{
    '^', // UP
    '>', // RIGHT
    'v', // DOWN
    '<', // LEFT
};

const Action = enum {
    Movement,
    Obstacle,
    Exit,
};

const data = @embedFile("data/day06.txt");
pub fn main() !void {
    var it = tokenizeSca(u8, data, '\n');
    var grid_list = List([]u8).init(gpa);
    while (it.next()) |line| {
        var line_list = List(u8).init(gpa);
        for (line) |char| {
            try line_list.append(char);
        }
        try grid_list.append(try line_list.toOwnedSlice());
    }
    var grid01 = try grid_list.toOwnedSlice();

    const grid_copy = try gpa.alloc([]u8, grid01.len);
    for (grid01, 0..) |r, i| {
        grid_copy[i] = try std.mem.Allocator.dupe(gpa, u8, r);
    }

    const initial_guard_pos = blk: {
        for (grid01, 0..) |row, i| {
            for (row, 0..) |cell, j| {
                if (contains(u8, &guard_direction, 1, &[_]u8{cell}))
                    break :blk Coords{ @intCast(i), @intCast(j) };
            }
        }
        return error.NotFound;
    };

    var guard_pos01 = initial_guard_pos;
    var visited_cells = try part01(&grid01, &guard_pos01);

    var grid02 = try gpa.alloc([]u8, grid_copy.len);
    for (grid_copy, 0..) |r, i| {
        grid02[i] = try std.mem.Allocator.dupe(gpa, u8, r);
    }

    var obstacles: u32 = 0;
    for (grid_copy, 0..) |row, x| {
        for (row, 0..) |cell, y| {
            for (grid02, 0..) |_, i| {
                @memcpy(grid02[i], grid_copy[i]);
            }
            var guard_pos02 = initial_guard_pos;
            if (cell == '#' or cell == '^') continue;

            grid02[x][y] = '#';
            obstacles += try part02(&grid02, &guard_pos02);
        }
    }

    print("***Day 06***\nPart 01: {}\nPart 02: {any}\n\n", .{ visited_cells.count(), obstacles });
}

fn part01(grid: *[][]u8, guard_pos: *Coords) !std.AutoHashMap(Coords, u8) {
    if (guard_pos[0] < 0 or guard_pos[1] < 0) return error.OutOfBounds;

    var movements = std.AutoHashMap(Coords, u8).init(gpa);
    defer movements.deinit();

    _ = try movements.getOrPut(guard_pos.*);
    var action: Action = .Obstacle;
    while (action != .Exit) {
        const dir = indexOf(u8, &guard_direction, grid.*[@intCast(guard_pos[0])][@intCast(guard_pos[1])]) orelse
            std.math.maxInt(usize);
        switch (dir) {
            0, 1, 2, 3 => {
                action = try tryMove(grid, guard_pos, dir);
            },
            else => return error.NotFound,
        }
        if (action == .Movement) {
            _ = try movements.getOrPut(guard_pos.*);
        }
    }

    return movements;
}

fn part02(grid: *[][]u8, guard_pos: *Coords) !u32 {
    if (guard_pos[0] < 0 or guard_pos[1] < 0) return error.OutOfBounds;

    var movements = std.AutoHashMap(Coords, u8).init(gpa);
    defer movements.deinit();

    _ = try movements.getOrPut(guard_pos.*);
    var action: Action = .Obstacle;
    while (action != .Exit) {
        const dir = indexOf(u8, &guard_direction, grid.*[@intCast(guard_pos[0])][@intCast(guard_pos[1])]) orelse
            std.math.maxInt(usize);
        switch (dir) {
            0, 1, 2, 3 => {
                action = try tryMove(grid, guard_pos, dir);
            },
            else => return error.NotFound,
        }
        if (action == .Movement) {
            const movement = try movements.getOrPut(guard_pos.*);
            const new_dir = indexOf(u8, &guard_direction, grid.*[@intCast(guard_pos[0])][@intCast(guard_pos[1])]) orelse
                std.math.maxInt(usize);
            if (movement.found_existing and movement.value_ptr.* == guard_direction[new_dir]) {
                return 1;
            } else {
                movement.value_ptr.* = grid.*[@intCast(guard_pos[0])][@intCast(guard_pos[1])];
            }
        }
    }

    return 0;
}

fn tryMove(grid: *[][]u8, guard_pos: *Coords, index: usize) !Action {
    const next_pos = Coords{
        guard_pos.*[0] + step_direction[index][0],
        guard_pos.*[1] + step_direction[index][1],
    };

    if (!inBounds(grid.*, next_pos)) return Action.Exit;

    if (grid.*[@intCast(next_pos[0])][@intCast(next_pos[1])] == '#') {
        grid.*[@intCast(guard_pos[0])][@intCast(guard_pos[1])] =
            guard_direction[(index + 1) % guard_direction.len];
        return Action.Obstacle;
    }

    grid.*[@intCast(next_pos[0])][@intCast(next_pos[1])] =
        grid.*[@intCast(guard_pos[0])][@intCast(guard_pos[1])];

    grid.*[@intCast(guard_pos[0])][@intCast(guard_pos[1])] = '.';
    guard_pos.* = next_pos;

    return Action.Movement;
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
