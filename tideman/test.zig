const std = @import("std");
const myFile = @import("tideman.zig");
const testing = std.testing;
const validateCandidates = myFile.validateCandidates;
const MyErrors = myFile.MyErrors;

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
