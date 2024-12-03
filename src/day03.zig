const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

pub fn main() !void {
    var result01: i64 = 0;
    var result02: i64 = 0;

    result01 = multiply(data);
    result02 = conditional_multiply(data);

    print("***Day 03***\nPart 01: {}\nPart 02: {}\n", .{ result01, result02 });
}

fn multiply(mul: []const u8) i64 {
    var current_index: usize = 0;
    var result: i64 = 0;
    while (current_index < mul.len) {
        const left_index = indexOfStr(u8, mul, current_index, "mul(") orelse break;
        const right_index = indexOfStr(u8, mul, left_index, ")") orelse break;
        defer current_index = left_index + 1;

        var operands = splitSca(u8, mul[left_index + 4 .. right_index], ',');

        const left_op = parseOperand(&operands) orelse continue;
        const right_op = parseOperand(&operands) orelse continue;

        result += left_op * right_op;
    }
    return result;
}

fn conditional_multiply(mul: []const u8) i64 {
    var current_index: usize = 0;
    var result: i64 = 0;
    var do = true;
    while (current_index < mul.len) {
        if (do) {
            const left_index = indexOfStr(u8, mul, current_index, "mul(") orelse break;
            const right_index = indexOfStr(u8, mul, left_index, ")") orelse break;

            if (indexOfStr(u8, mul, current_index, "don't()")) |dont_pos| {
                if (right_index >= dont_pos) {
                    do = false;
                    current_index = dont_pos + "don't()".len;
                    continue;
                }
            }

            var operands = splitSca(u8, mul[left_index + 4 .. right_index], ',');
            const left_op = parseOperand(&operands) orelse {
                current_index = left_index + 1;
                continue;
            };
            const right_op = parseOperand(&operands) orelse {
                current_index = left_index + 1;
                continue;
            };

            result += left_op * right_op;
            current_index = left_index + 1;
        } else if (indexOfStr(u8, mul, current_index, "do()")) |do_pos| {
            current_index = do_pos + "do()".len;
            do = true;
        } else break;
    }
    return result;
}

fn parseOperand(operands: *std.mem.SplitIterator(u8, .scalar)) ?i64 {
    const next_item = operands.next() orelse return null;
    return parseInt(i64, next_item, 10) catch return null;
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
const indexOfStr = std.mem.indexOfPos;
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
