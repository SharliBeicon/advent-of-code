const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;

const indexOfSca = std.mem.indexOfScalar;
const indexOfSec = std.mem.indexOf;
const lastIndexOfSec = std.mem.lastIndexOf;
const print = std.debug.print;
const contains = std.mem.containsAtLeast;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

pub fn main() !void {
    var filesystem_list = List(i64).init(gpa);
    defer filesystem_list.deinit();

    var block_idx: usize = 0;
    for (data, 0..) |d, i| {
        if (d >= '0' and d <= '9') {
            const ascii_digit = d - '0';
            var j: usize = 0;
            if (i % 2 == 0) {
                while (j < ascii_digit) : (j += 1) {
                    try filesystem_list.append(@as(i64, @intCast(block_idx)));
                }
                block_idx += 1;
            } else {
                while (j < ascii_digit) : (j += 1) {
                    try filesystem_list.append(@as(i64, -1));
                }
            }
        }
    }
    const filesystem01 = try filesystem_list.toOwnedSlice();
    const filesystem02 = try Allocator.dupe(gpa, i64, filesystem01);

    const part01 = try std.Thread.spawn(.{}, checksum_part01, .{filesystem01});
    const part02 = try std.Thread.spawn(.{}, checksum_part02, .{filesystem02});

    print("***Day 09***\n", .{});
    part01.join();
    part02.join();
}

fn checksum_part01(filesystem: []i64) void {
    var i: usize = 0;
    var j: usize = filesystem.len - 1;
    var aux: i64 = 0;
    while (i < j) {
        if (filesystem[i] == -1 and filesystem[j] != -1) {
            aux = filesystem[i];
            filesystem[i] = filesystem[j];
            filesystem[j] = aux;

            i += 1;
            j -= 1;
        } else if (filesystem[i] == -1) {
            j -= 1;
        } else {
            i += 1;
        }
    }

    var result: i64 = 0;
    var idx: usize = 0;
    while (filesystem[idx] != -1) : (idx += 1) {
        result += filesystem[idx] * @as(i64, @intCast(idx));
    }

    print("Part 01: {}\n", .{result});
}

fn checksum_part02(filesystem: []i64) !void {
    var i: isize = @intCast(filesystem.len - 1);
    var needle: i64 = filesystem[@intCast(i)];
    outer_loop: while (i >= 0) {
        while (i >= 0 and filesystem[@intCast(i)] == -1) {
            i -= 1;
            if (i < 0) break :outer_loop;
        }
        const needle_end: usize = @intCast(i + 1);
        needle = filesystem[@intCast(i)];
        while (i >= 0 and filesystem[@intCast(i)] == needle) {
            i -= 1;
            if (i <= 0) break :outer_loop;
        }
        const needle_start: usize = @intCast(i + 1);
        const block_size = needle_end - needle_start;
        const block = try gpa.alloc(i64, block_size);
        defer gpa.free(block);
        for (block) |*b| {
            b.* = -1;
        }
        const block_index = indexOfSec(i64, filesystem, block);
        if (block_index) |bi| {
            if (bi < needle_start) {
                var id: usize = bi;
                var del_id: usize = needle_start;
                while (id < bi + block_size) : (id += 1) {
                    filesystem[id] = needle;
                    filesystem[del_id] = -1;
                    del_id += 1;
                }
            }
        }
    }

    var result: i64 = 0;
    var idx: usize = 0;
    while (idx < filesystem.len) : (idx += 1) {
        if (filesystem[idx] != -1) {
            result += filesystem[idx] * @as(i64, @intCast(idx));
        }
    }

    print("Part 02: {}\n", .{result});
}
