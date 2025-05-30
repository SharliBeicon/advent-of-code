const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const parseInt = std.fmt.parseInt;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day13.txt");

pub fn main() !void {
    const regex = try util.Regex.init("[0-9]+");
    defer regex.deinit();

    const capture = regex.captures(data);

    const block_size: usize = 6;
    var tokens_p1: i128 = 0;
    var tokens_p2: i128 = 0;
    if (capture) |list| {
        var i: usize = 0;
        var memo01 = Map(@Vector(4, i128), i128).init(gpa);
        defer memo01.deinit();
        while (i < list.len) : (i += block_size) {
            const s = list[i .. i + block_size];
            const cur_tokens = getTokensPart01(
                try parseInt(i128, s[0], 10),
                try parseInt(i128, s[1], 10),
                try parseInt(i128, s[2], 10),
                try parseInt(i128, s[3], 10),
                try parseInt(i128, s[4], 10),
                try parseInt(i128, s[5], 10),
                0,
                0,
                &memo01,
            );

            memo01.clearAndFree();
            if (cur_tokens < std.math.maxInt(i32)) tokens_p1 += cur_tokens;
        }

        i = 0;
        while (i < list.len) : (i += block_size) {
            const s = list[i .. i + block_size];
            const cur_tokens = getTokensPart02(
                try parseInt(i128, s[0], 10),
                try parseInt(i128, s[1], 10),
                try parseInt(i128, s[2], 10),
                try parseInt(i128, s[3], 10),
                try parseInt(i128, s[4], 10),
                try parseInt(i128, s[5], 10),
            );

            tokens_p2 += cur_tokens;
        }
    }

    std.debug.print("***Day 13***\nPart 01: {}\nPart 02: {}\n\n", .{ tokens_p1, tokens_p2 });
}

fn getTokensPart01(
    ax: i128,
    ay: i128,
    bx: i128,
    by: i128,
    x: i128,
    y: i128,
    a_count: u8,
    b_count: u8,
    memo: *Map(@Vector(4, i128), i128),
) i128 {
    if (x < 0 or y < 0 or (b_count > 100 and a_count > 100)) return std.math.maxInt(i32);

    if (memo.get(.{ @intCast(x), @intCast(y), a_count, b_count })) |c| return c;

    if (x == 0 and y == 0) return 0;

    const result = if (a_count < 100 and b_count < 100)
        @min(
            3 + getTokensPart01(ax, ay, bx, by, x - ax, y - ay, a_count + 1, b_count, memo),
            1 + getTokensPart01(ax, ay, bx, by, x - bx, y - by, a_count, b_count + 1, memo),
        )
    else if (a_count <= 100)
        3 + getTokensPart01(ax, ay, bx, by, x - ax, y - ay, a_count + 1, b_count, memo)
    else
        1 + getTokensPart01(ax, ay, bx, by, x - ax, y - ay, a_count, b_count + 1, memo);

    memo.put(.{ @intCast(x), @intCast(y), a_count, b_count }, result) catch return result;
    return result;
}

fn getTokensPart02(
    ax: i128,
    ay: i128,
    bx: i128,
    by: i128,
    x: i128,
    y: i128,
) i128 {
    const nx = 10_000_000_000_000 + x;
    const ny = 10_000_000_000_000 + y;

    const a: i128 = @divFloor(-bx * ny + by * nx, ax * by - ay * bx);
    const b: i128 = @divFloor(ax * ny - ay * nx, ax * by - ay * bx);
    if (ax * a + bx * b == nx and ay * a + by * b == ny) {
        return 3 * a + b;
    }

    return 0;
}
