const std = @import("std");
const List = std.ArrayList;
const gpa = std.heap.page_allocator;

const tokenizeSca = std.mem.tokenizeScalar;
const print = std.debug.print;
const eql = std.mem.eql;

const Coords = @Vector(2, isize);
const directions = [_]Coords{
    .{ 0, -1 }, // UP
    .{ 0, 1 }, // DOWN
    .{ -1, 0 }, // LEFT
    .{ 1, 0 }, // RIGHT
    .{ -1, -1 }, // UP LEFT
    .{ 1, -1 }, // UP RIGHT
    .{ -1, 1 }, // DOWN LEFT
    .{ 1, 1 }, // DOWN RIGHT
};

pub fn main() !void {
    const file = @embedFile("data/day04.txt");
    var data = std.mem.tokenizeScalar(u8, file, '\n');

    var letter_soup = List([]const u8).init(gpa);
    defer letter_soup.deinit();
    var x_positions = List(Coords).init(gpa);
    defer x_positions.deinit();
    var a_positions = List(Coords).init(gpa);
    defer a_positions.deinit();

    var i: usize = 0;
    while (data.next()) |row| {
        try letter_soup.append(row);
        for (row, 0..) |cell, j| {
            if (cell == 'X') try x_positions.append(.{ @intCast(i), @intCast(j) });
            if (cell == 'A') try a_positions.append(.{ @intCast(i), @intCast(j) });
        }
        i += 1;
    }

    // PART 1
    const xmas_count = xmasCount(letter_soup, x_positions);

    // PART 2
    const x_mas_count = x_masCount(letter_soup, a_positions);

    print("***Day 04***\nPart 01: {}\nPart 02: {}\n", .{ xmas_count, x_mas_count });
}

fn xmasCount(letter_soup: List([]const u8), x_positions: List(Coords)) u32 {
    var result: u32 = 0;

    for (x_positions.items) |x_position| {
        for (directions) |direction| {
            const next_pos = Coords{
                x_position[0] + direction[0],
                x_position[1] + direction[1],
            };
            result += searchXmas(letter_soup, 'M', next_pos, direction);
        }
    }
    return result;
}

fn searchXmas(
    letter_soup: List([]const u8),
    required_char: u8,
    current_pos: Coords,
    direction: Coords,
) u32 {
    const next_pos = Coords{
        current_pos[0] + direction[0],
        current_pos[1] + direction[1],
    };

    const current_char = safeCharAccess(letter_soup, current_pos[0], current_pos[1]) orelse return 0;

    return if (required_char == current_char)
        switch (current_char) {
            'M' => searchXmas(letter_soup, 'A', next_pos, direction),
            'A' => searchXmas(letter_soup, 'S', next_pos, direction),
            'S' => 1,
            else => 0,
        }
    else
        0;
}

fn x_masCount(letter_soup: List([]const u8), a_positions: List(Coords)) u32 {
    var result: u32 = 0;
    for (a_positions.items) |a_position| {
        const up_left = safeCharAccess(letter_soup, a_position[0] + directions[4][0], a_position[1] + directions[4][1]) orelse continue;
        const up_right = safeCharAccess(letter_soup, a_position[0] + directions[5][0], a_position[1] + directions[5][1]) orelse continue;
        const a = letter_soup.items[@intCast(a_position[0])][@intCast(a_position[1])];
        const down_left = safeCharAccess(letter_soup, a_position[0] + directions[6][0], a_position[1] + directions[6][1]) orelse continue;
        const down_right = safeCharAccess(letter_soup, a_position[0] + directions[7][0], a_position[1] + directions[7][1]) orelse continue;

        const word1 = [3]u8{ up_left, a, down_right };
        const word2 = [3]u8{ up_right, a, down_left };
        if ((eql(u8, &word1, "MAS") or eql(u8, &word1, "SAM")) and
            (eql(u8, &word2, "MAS") or eql(u8, &word2, "SAM"))) result += 1;
    }

    return result;
}

fn safeCharAccess(
    letter_soup: List([]const u8),
    row: isize,
    col: isize,
) ?u8 {
    if (row >= 0 and
        col >= 0 and
        row < @as(isize, @intCast(letter_soup.items.len)) and
        col < @as(isize, @intCast(letter_soup.items[0].len)))
    {
        return letter_soup.items[@intCast(row)][@intCast(col)];
    }
    return null;
}
