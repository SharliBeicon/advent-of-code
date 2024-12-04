//! https://adventofcode.com/2024/day/3

const std = @import("std");
const util = @import("util.zig");
const gpa = util.gpa;

const splitSca = std.mem.splitScalar;
const indexOfStr = std.mem.indexOfPos;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

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

        var operands = splitSca(u8, mul[left_index + "mul(".len .. right_index], ',');

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

            var operands = splitSca(u8, mul[left_index + "mul(".len .. right_index], ',');
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
