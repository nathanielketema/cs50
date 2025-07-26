const std = @import("std");

pub const byte = u8;
pub const dword = u32;
pub const long = i32;
pub const word = u16;

pub const BitMapFileHeader = packed struct {
    bf_type: word,
    bf_size: dword,
    bf_reserved_1: word,
    bf_reserved_2: word,
    bf_off_bits: dword,
};

pub const BitMapInfoHeader = packed struct {
    bit_size: dword,
    bit_width: long,
    bit_height: long,
    bit_planes: word,
    bit_bit_count: word,
    bit_compression: dword,
    bit_size_image: dword,
    bit_x_pels_per_meter: long,
    bit_y_pels_per_meter: long,
    bit_clr_used: dword,
    bit_clr_important: dword,
};

pub const RGBTriple = packed struct {
    blue: byte,
    green: byte,
    red: byte,
};
