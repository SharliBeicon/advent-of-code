const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const parseInt = std.fmt.parseInt;

const data = @embedFile("data/day14.txt");

const Position = @Vector(2, usize);
const Velocity = @Vector(2, isize);

const Robot = struct {
    position: Position,
    velocity: Velocity,
};

const WIDTH = 101;
const HEIGHT = 103;

pub fn main() !void {
    const regex = try util.Regex.init("-?[0-9]+");
    defer regex.deinit();

    var robots_list = List(Robot).init(gpa);
    var robots: []Robot = undefined;
    defer gpa.free(robots);

    const capture = regex.captures(data);
    const input_size: usize = 4;
    var input_index: usize = 0;
    if (capture) |c| {
        while (input_index < c.len) {
            const s = c[input_index .. input_index + input_size];
            try robots_list.append(.{
                .position = .{
                    try parseInt(usize, s[0], 10),
                    try parseInt(usize, s[1], 10),
                },
                .velocity = .{
                    try parseInt(isize, s[2], 10),
                    try parseInt(isize, s[3], 10),
                },
            });
            input_index += input_size;
        }
        robots = try robots_list.toOwnedSlice();
        robots_list.deinit();
    }

    const robots_part02: []Robot = try Allocator.dupe(gpa, Robot, robots);
    @memcpy(robots_part02, robots);
    defer gpa.free(robots_part02);

    const safety_factor: u64 = safetyFactor(robots);
    std.debug.print("{}\n", .{safety_factor});

    drawTree(robots_part02);
}

fn safetyFactor(robots: []Robot) u64 {
    var quadrants: @Vector(4, u64) = .{ 0, 0, 0, 0 };
    for (robots, 0..) |_, i| {
        for (0..100) |_| {
            const robot_x: isize = @intCast(robots[i].position[0]);
            const robot_y: isize = @intCast(robots[i].position[1]);

            const new_pos_x: usize = @intCast(@mod((robot_x + robots[i].velocity[0]), WIDTH));
            const new_pos_y: usize = @intCast(@mod((robot_y + robots[i].velocity[1]), HEIGHT));

            robots[i].position[0] = new_pos_x;
            robots[i].position[1] = new_pos_y;
        }

        const middle_x = @divFloor(WIDTH, 2);
        const middle_y = @divFloor(HEIGHT, 2);
        if (robots[i].position[0] < middle_x and robots[i].position[1] < middle_y) quadrants[0] += 1;
        if (robots[i].position[0] < middle_x and robots[i].position[1] > middle_y) quadrants[1] += 1;
        if (robots[i].position[0] > middle_x and robots[i].position[1] < middle_y) quadrants[2] += 1;
        if (robots[i].position[0] > middle_x and robots[i].position[1] > middle_y) quadrants[3] += 1;
    }

    return quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3];
}

fn drawTree(robots: []Robot) void {
    var i: usize = 1;
    var set = Map(Position, void).init(gpa);
    defer set.deinit();

    var c: usize = 0;
    while (c < 10_000) : (c += 1) {
        for (robots, 0..) |_, ri| {
            const robot_x: isize = @intCast(robots[ri].position[0]);
            const robot_y: isize = @intCast(robots[ri].position[1]);

            const new_pos_x: usize = @intCast(@mod((robot_x + robots[ri].velocity[0]), WIDTH));
            const new_pos_y: usize = @intCast(@mod((robot_y + robots[ri].velocity[1]), HEIGHT));

            robots[ri].position[0] = new_pos_x;
            robots[ri].position[1] = new_pos_y;

            set.put(robots[ri].position, {}) catch continue;
        }
        std.debug.print("AFTER {}: \n", .{i});
        i += 1;
        for (0..HEIGHT) |y| {
            for (0..WIDTH) |x| {
                if (set.contains(.{ x, y })) {
                    std.debug.print("X", .{});
                } else {
                    std.debug.print(".", .{});
                }
            }
            std.debug.print("\n", .{});
        }
        set.clearAndFree();
    }
}
