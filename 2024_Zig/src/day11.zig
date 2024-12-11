const std = @import("std");
const List = std.ArrayList;
const HashMap = std.AutoHashMap;

const tokenizeSca = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");
const Pair = @Vector(2, u64);

pub fn main() !void {
    var it = tokenizeSca(u8, data[0 .. data.len - 1], ' ');

    var map01 = HashMap(Pair, u64).init(gpa);
    defer map01.deinit();
    var map02 = HashMap(Pair, u64).init(gpa);
    defer map02.deinit();

    var list = List(u64).init(gpa);
    defer list.deinit();

    while (it.next()) |item| {
        const n = parseInt(u64, item, 10) catch continue;
        try list.append(n);
    }

    var part01: u64 = 0;
    var part02: u64 = 0;
    for (list.items) |item| {
        part01 += try computeCorridor(&map01, item, 25);
        part02 += try computeCorridor(&map02, item, 75);
    }

    print("***DAY 11***\nPart 01: {}\nPart 02: {}\n\n", .{ part01, part02 });
}

fn computeCorridor(map: *HashMap(Pair, u64), item: u64, n: usize) !u64 {
    if (n == 0) return 1;

    const digits: u64 = if (item == 0) 1 else std.math.log10(item) + 1;

    var result: u64 = 0;
    const cache = map.getEntry(.{ item, n });
    if (cache) |res| {
        return res.value_ptr.*;
    } else {
        if (item == 0) {
            result = try computeCorridor(map, 1, n - 1);
        } else if (digits % 2 == 0) {
            const half_digits = digits / 2;
            const divisor = std.math.pow(u64, 10, half_digits);

            const first_half: u64 = item / divisor;
            const second_half: u64 = item % divisor;

            result = try computeCorridor(map, first_half, n - 1) + try computeCorridor(map, second_half, n - 1);
        } else {
            result = try computeCorridor(map, 2024 * item, n - 1);
        }

        try map.put(.{ item, n }, result);
    }

    return result;
}
