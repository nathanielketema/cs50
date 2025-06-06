const std = @import("std");
const testing = std.testing;

const print = std.debug.print;

const Score = struct {
    letter: u8 = undefined,
    value: u8 = undefined
};

const scoring = [_]Score { 
    .{ .letter = 'A', .value = 1 }, .{ .letter = 'B', .value = 3 }, 
    .{ .letter = 'C', .value = 3 }, .{ .letter = 'D', .value = 2 }, 
    .{ .letter = 'E', .value = 1 }, .{ .letter = 'F', .value = 4 }, 
    .{ .letter = 'G', .value = 2 }, .{ .letter = 'H', .value = 4 }, 
    .{ .letter = 'I', .value = 1 }, .{ .letter = 'J', .value = 8 }, 
    .{ .letter = 'K', .value = 5 }, .{ .letter = 'L', .value = 1 }, 
    .{ .letter = 'M', .value = 3 }, .{ .letter = 'N', .value = 1 }, 
    .{ .letter = 'O', .value = 1 }, .{ .letter = 'P', .value = 3 }, 
    .{ .letter = 'Q', .value = 10 }, .{ .letter = 'R', .value = 1 }, 
    .{ .letter = 'S', .value = 1 }, .{ .letter = 'T', .value = 1 }, 
    .{ .letter = 'U', .value = 1 }, .{ .letter = 'V', .value = 4 }, 
    .{ .letter = 'W', .value = 4 }, .{ .letter = 'X', .value = 8 }, 
    .{ .letter = 'Y', .value = 4 }, .{ .letter = 'Z', .value = 10 } 
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [30]u8 = undefined;

    print("Player 1: ", .{});
    const player1 = try stdin.readUntilDelimiterOrEof(&buffer, '\n');

    const player1Score = getScore(player1 orelse return);

    print("Player 2: ", .{});
    const player2 = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    const player2Score = getScore(player2.?); // player2.? -> player2 orelse unreachable

    if (player1Score > player2Score) {
        print("Player 1 wins\n", .{});
    } else if (player1Score < player2Score) {
        print("Player 2 wins\n", .{});
    } else {
        print("Tie!\n", .{});
    }
}

fn getScore(word: []const u8) u8 {
    var sum: u8 = 0;
    for (word) |w| {
        const l: u8 = std.ascii.toUpper(w);
        for (scoring) |s| {
            if (l == s.letter) {
                sum += s.value;
            }
        }
    }
    return sum;
}
