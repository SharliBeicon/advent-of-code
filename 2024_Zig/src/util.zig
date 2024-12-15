const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const c = @cImport({
    @cInclude("regex.h");
    @cInclude("../lib/regex_slim.h");
});

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

pub const Regex = struct {
    inner: *c.regex_t,

    pub fn init(pattern: [:0]const u8) !Regex {
        const inner = c.alloc_regex_t().?;
        if (0 != c.regcomp(inner, pattern, c.REG_NEWLINE | c.REG_EXTENDED)) {
            return error.compile;
        }

        return .{
            .inner = inner,
        };
    }

    pub fn deinit(self: Regex) void {
        c.free_regex_t(self.inner);
    }

    pub fn matches(self: Regex, input: [:0]const u8) bool {
        const match_size = 1;
        var pmatch: [match_size]c.regmatch_t = undefined;
        return 0 == c.regexec(self.inner, input, match_size, &pmatch, 0);
    }

    pub fn captures(self: Regex, input: [:0]const u8) ?[][]const u8 {
        const match_size = 1;
        var pmatch: [match_size]c.regmatch_t = undefined;
        var result = List([]const u8).init(gpa);
        defer result.deinit();

        var string = input;
        while (true) {
            if (0 != c.regexec(self.inner, string, match_size, &pmatch, 0)) break;

            const slice = string[@as(usize, @intCast(pmatch[0].rm_so))..@as(usize, @intCast(pmatch[0].rm_eo))];
            result.append(slice) catch break;

            string = string[@intCast(pmatch[0].rm_eo)..];
        }

        if (result.items.len == 0)
            return null
        else
            return result.toOwnedSlice() catch null;
    }
};
