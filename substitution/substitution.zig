const std = @import("std");
const stdin = std.io.getStdIn().reader();
const print = std.debug.print;
const testing = std.testing;

const InputKeyError = error{
    MissingArgument,
    LengthNot26,
    NotAlphabetic,
    NotUnique,
};

pub fn main() !void {
    const argv = std.os.argv;
    if (argv.len != 2) {
        printErrorMessage(InputKeyError.MissingArgument);
        return;
    }
    const temp = std.mem.span(argv[1]);
    if (temp.len != 26) {
        printErrorMessage(InputKeyError.LengthNot26);
        return;
    }
    for (temp) |c| {
        if (!std.ascii.isAlphabetic(c)) {
            printErrorMessage(InputKeyError.NotAlphabetic);
            return;
        }
    }
    for (temp, 0..) |c, i| {
        for (temp[i + 1 ..]) |cj| {
            if (c == cj) {
                printErrorMessage(InputKeyError.NotUnique);
                return;
            }
        }
    }
    const key = temp;
    var buffer: [10]u8 = undefined;
    print("plaintext: ", .{});
    const plaintext = stdin.readUntilDelimiterOrEof(&buffer, '\n') catch unreachable;
    const cipher: []const u8 = encipher(plaintext.?, key);
    print("ciphertext: {s}\n", .{cipher});
}

fn encipher(text: []u8, key: []u8) []u8 {
    var index: u8 = undefined;
    for (text) |*c| {
        if (!std.ascii.isAlphabetic(c.*)) continue;
        if (std.ascii.isLower(c.*)) {
            index = c.* - 97;
            c.* = std.ascii.toLower(key[index]);
        } else {
            index = c.* - 65;
            c.* = std.ascii.toUpper(key[index]);
        }
    }
    return text;
}

fn printErrorMessage(err: InputKeyError) void {
    switch (err) {
        InputKeyError.MissingArgument => print("Usage: zig run ./substitution.zig -- key\n", .{}),
        InputKeyError.LengthNot26 => print("Key must contain 26 characters.\n", .{}),
        InputKeyError.NotAlphabetic => print("Key must only contain alphabetic characters.\n", .{}),
        InputKeyError.NotUnique => print("Key must not contain repeated characters.\n", .{}),
        else => unreachable,
    }
}
