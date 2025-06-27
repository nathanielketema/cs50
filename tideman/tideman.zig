const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const stdin = std.io.getStdIn().reader();

var pair_count: usize = 0;
var candidate_count: usize = 0;

const pair = struct {
    winner: []const u8 = undefined,
    loser: []const u8 = undefined,
};

pub const MyErrors = error{
    ArgumentNotSatisfied,
    CandidateNotAlphabetic,
};

pub fn main() !void {
    const args: [][*:0]u8 = std.os.argv;
    validateCandidates(args) catch |err| {
        printErrorMessage(err);
        return;
    };
    candidate_count = args.len - 1;
    var candidates: [9][]u8 = undefined;
    for (args[1..], 0..) |candidate, i| {
        candidates[i] = std.mem.span(candidate);
    }

    print("Number of voters: ", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const buffer: []u8 = try allocator.alloc(u8, 5);
    defer allocator.free(buffer);

    const user_input: ?[]const u8 = stdin.readUntilDelimiterOrEof(buffer, '\n') catch unreachable;
    const number_of_voters: u8 = try std.fmt.parseInt(u8, user_input.?, 0);
    _ = number_of_voters;
}

pub fn validateCandidates(args: [][*:0]u8) MyErrors!void {
    if (args.len < 3 or args.len > 10) {
        return MyErrors.ArgumentNotSatisfied;
    }

    for (args[1..]) |candidate| {
        for (std.mem.span(candidate)) |c| {
            if (!std.ascii.isAlphabetic(c)) {
                return MyErrors.CandidateNotAlphabetic;
            }
        }
    }
}

fn printErrorMessage(err: MyErrors) void {
    switch (err) {
        MyErrors.ArgumentNotSatisfied => {
            print("A minimum of 2 and a maximum of 9 candidates allowed\n", .{});
            print("\n", .{});
            print("Usage: zig run tideman.zig -- Candidate1 Candidate2 [Candidate3]..[Candidate9]\n", .{});
        },
        MyErrors.CandidateNotAlphabetic => print("Candidate must be alphabetic!\n", .{}),
        else => unreachable,
    }
}

test "validate candidate - 2 candidates" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob = "Bob".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob),
    };

    try validateCandidates(&args);
}

test "validate candidate - only 1 candidate" {
    var program_name = "tideman".*;
    var alice = "Alice".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
    };

    try testing.expectError(MyErrors.ArgumentNotSatisfied, validateCandidates(&args));
}

test "validate candidate - no candidates" {
    var program_name = "tideman".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
    };

    try testing.expectError(MyErrors.ArgumentNotSatisfied, validateCandidates(&args));
}

test "validate candidate - too many candidates (10)" {
    var program_name = "tideman".*;
    var a = "A".*;
    var b = "B".*;
    var c = "C".*;
    var d = "D".*;
    var e = "E".*;
    var f = "F".*;
    var g = "G".*;
    var h = "H".*;
    var i = "I".*;
    var j = "J".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&a),
        @ptrCast(&b),
        @ptrCast(&c),
        @ptrCast(&d),
        @ptrCast(&e),
        @ptrCast(&f),
        @ptrCast(&g),
        @ptrCast(&h),
        @ptrCast(&i),
        @ptrCast(&j),
    };

    try testing.expectError(MyErrors.ArgumentNotSatisfied, validateCandidates(&args));
}

test "validate candidate - numeric characters" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob2 = "Bob2".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob2),
    };

    try testing.expectError(MyErrors.CandidateNotAlphabetic, validateCandidates(&args));
}

test "validate candidate - special characters" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob_exclaim = "Bob!".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob_exclaim),
    };

    try testing.expectError(MyErrors.CandidateNotAlphabetic, validateCandidates(&args));
}

test "validate candidate - maximum 9 candidates" {
    var program_name = "tideman".*;
    var alice = "Alice".*;
    var bob = "Bob".*;
    var charlie = "Charlie".*;
    var david = "David".*;
    var eve = "Eve".*;
    var frank = "Frank".*;
    var grace = "Grace".*;
    var henry = "Henry".*;
    var ivy = "Ivy".*;

    var args = [_][*:0]u8{
        @ptrCast(&program_name),
        @ptrCast(&alice),
        @ptrCast(&bob),
        @ptrCast(&charlie),
        @ptrCast(&david),
        @ptrCast(&eve),
        @ptrCast(&frank),
        @ptrCast(&grace),
        @ptrCast(&henry),
        @ptrCast(&ivy),
    };

    try validateCandidates(&args);
}
