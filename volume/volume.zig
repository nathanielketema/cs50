const std = @import("std");
const stdin = std.io.getStdIn().reader();
const print = std.debug.print;
const testing = std.testing;
const assert = std.debug.assert;

const header_size = 44;

pub fn main() !void {
    // 3 input from the command line:
    //     - input file (eg: input.wav)
    //     - output file (eg: output.wav)
    //     - factor (eg: 2.0, 0.5, 5)

    // Validate command line input
    //     - all inputs provided?
    //     - does input file exist?
    //     - does input file has the right extension
    //     - does output has the right extension
    //     - does output file has right file name
    //     - is the factor a number
    //     - is the factor > 0

    // Read header from the input file
    // Write header to the output file
    // For each sample:
    //     Read sample from input file
    //     Multiply sample by factor
    //     Write new sample to the output file
}

test "test name" {
}
