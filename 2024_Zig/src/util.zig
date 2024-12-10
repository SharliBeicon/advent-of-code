const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = gpa_impl.allocator();

pub fn inBounds(
    grid: [][]const u8,
    pos: @Vector(2, isize),
) bool {
    return (pos[0] >= 0 and
        pos[1] >= 0 and
        pos[0] < @as(isize, @intCast(grid.len)) and
        pos[1] < @as(isize, @intCast(grid[0].len)));
}
