const std = @import("std");

pub const BitMapFileHeader = packed struct {
    bf_type: u16,
    bf_size: u32,
    bf_reserved_1: u16,
    bf_reserved_2: u16,
    bf_off_bits: u32,
};

pub const BitMapInfoHeader = packed struct {
    bit_size: u32,
    bit_width: i32,
    bit_height: i32,
    bit_planes: u16,
    bit_bit_count: u16,
    bit_compression: u32,
    bit_size_image: u32,
    bit_x_pels_per_meter: i32,
    bit_y_pels_per_meter: i32,
    bit_clr_used: u32,
    bit_clr_important: u32,
};

pub const RGBTriple = packed struct {
    blue: u8,
    green: u8,
    red: u8,
};
