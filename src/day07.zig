const std = @import("std");
const List = std.ArrayList;
const Map = std.AutoHashMap;

const util = @import("util.zig");
const gpa = util.gpa;

const print = std.debug.print;
const tokenizeSca = std.mem.tokenizeScalar;
const splitSca = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;
const allocPrint = std.fmt.allocPrint;

const data = @embedFile("data/day07.txt");

pub fn main() !void {
    var map = Map(u64, []u64).init(gpa);
    defer map.deinit();

    var it = tokenizeSca(u8, data, '\n');
    while (it.next()) |row| {
        var list = List(u64).init(gpa);
        defer list.deinit();

        var split = splitSca(u8, row, ':');
        const key = split.next().?;
        const entry = try map.getOrPut(try parseInt(u64, key, 10));

        var operands = tokenizeSca(u8, split.next().?, ' ');
        while (operands.next()) |op| {
            try list.append(try parseInt(u64, op, 10));
        }

        entry.value_ptr.* = try list.toOwnedSlice();
    }

    const calibration_result = try calibrateBridge(map);
    print("***Day 07***\nPart 01: {}\nPart 02: {any}\n\n", .{ calibration_result.part01, calibration_result.part02 });
}

fn calibrateBridge(map: Map(u64, []u64)) !struct { part01: u64, part02: u64 } {
    var it = map.iterator();
    var part01: u64 = 0;
    var part02: u64 = 0;
    while (it.next()) |entry| {
        const target = entry.key_ptr.*;
        const operands = entry.value_ptr.*;

        if (isValidCalibration(target, operands, operands[0], 0)) {
            part01 += target;
        }

        if (try isValidCalibrationiWithConcat(target, operands, operands[0], 0)) {
            part02 += target;
        }
    }

    return .{ .part01 = part01, .part02 = part02 };
}

fn isValidCalibration(target: u64, operands: []u64, current: u64, index: usize) bool {
    if (index >= operands.len - 1) return target == current;

    const new_index = index + 1;
    return isValidCalibration(target, operands, current + operands[new_index], new_index) or
        isValidCalibration(target, operands, current * operands[new_index], new_index);
}

fn isValidCalibrationiWithConcat(target: u64, operands: []u64, current: u64, index: usize) !bool {
    if (index >= operands.len - 1) return target == current;

    const new_index = index + 1;
    const str1 = try allocPrint(gpa, "{d}", .{current});
    const str2 = try allocPrint(gpa, "{d}", .{operands[new_index]});
    const concated = try std.mem.concat(gpa, u8, &[_][]const u8{ str1, str2 });
    const concated_num = try parseInt(u64, concated, 10);
    return try isValidCalibrationiWithConcat(target, operands, current + operands[new_index], new_index) or
        try isValidCalibrationiWithConcat(target, operands, current * operands[new_index], new_index) or
        try isValidCalibrationiWithConcat(target, operands, concated_num, new_index);
}
