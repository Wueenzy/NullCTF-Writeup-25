const std = @import("std");
const crypto = std.crypto;

const BLOCK_SIZE = 16;

fn pad(data: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const pad_len = BLOCK_SIZE - (data.len % BLOCK_SIZE);
    const padded = try allocator.alloc(u8, data.len + pad_len);
    @memcpy(padded[0..data.len], data);
    @memset(padded[data.len..], @intCast(pad_len));
    return padded;
}

fn unpad(data: []const u8) ![]const u8 {
    if (data.len == 0 or data.len % BLOCK_SIZE != 0) {
        return error.InvalidPadding;
    }
    const pad_len = data[data.len - 1];
    if (pad_len == 0 or pad_len > BLOCK_SIZE) {
        return error.InvalidPadding;
    }
    for (data[data.len - pad_len ..]) |b| {
        if (b != pad_len) {
            return error.InvalidPadding;
        }
    }
    return data[0 .. data.len - pad_len];
}

fn xorBlocks(dst: *[BLOCK_SIZE]u8, a: [BLOCK_SIZE]u8, b: [BLOCK_SIZE]u8) void {
    for (dst, a, b) |*d, x, y| {
        d.* = x ^ y;
    }
}

fn sch3m3Encrypt(pt: []const u8, key: [BLOCK_SIZE]u8, iv: [BLOCK_SIZE]u8, allocator: std.mem.Allocator) ![]u8 {
    if (pt.len % BLOCK_SIZE != 0) {
        return error.InvalidLength;
    }

    const ctx = crypto.core.aes.AesDecryptCtx(crypto.core.aes.Aes128).init(key);
    const ct = try allocator.alloc(u8, pt.len);

    var prev_block = iv;
    var i: usize = 0;
    while (i < pt.len) : (i += BLOCK_SIZE) {
        var block: [BLOCK_SIZE]u8 = undefined;
        @memcpy(&block, pt[i..][0..BLOCK_SIZE]);

        var decrypted: [BLOCK_SIZE]u8 = undefined;
        ctx.decrypt(&decrypted, &block);

        xorBlocks(ct[i..][0..BLOCK_SIZE], decrypted, prev_block);
        prev_block = block;
    }

    return ct;
}

fn sch3m3Decrypt(ct: []const u8, key: [BLOCK_SIZE]u8, iv: [BLOCK_SIZE]u8, allocator: std.mem.Allocator) ![]u8 {
    if (ct.len % BLOCK_SIZE != 0) {
        return error.InvalidLength;
    }

    const ctx = crypto.core.aes.AesEncryptCtx(crypto.core.aes.Aes128).init(key);
    const pt = try allocator.alloc(u8, ct.len);

    var prev_block = iv;
    var i: usize = 0;
    while (i < ct.len) : (i += BLOCK_SIZE) {
        var block: [BLOCK_SIZE]u8 = undefined;
        @memcpy(&block, ct[i..][0..BLOCK_SIZE]);

        var xored: [BLOCK_SIZE]u8 = undefined;
        xorBlocks(&xored, block, prev_block);

        var encrypted: [BLOCK_SIZE]u8 = undefined;
        ctx.encrypt(&encrypted, &xored);

        @memcpy(pt[i..][0..BLOCK_SIZE], &encrypted);
        prev_block = encrypted;
    }

    return pt;
}

fn isValid(ct: []const u8, flag_enc: []const u8, allocator: std.mem.Allocator) !bool {
    const padded_ct = try pad(ct, allocator);
    defer allocator.free(padded_ct);

    var i: usize = 0;
    while (i < padded_ct.len) : (i += BLOCK_SIZE) {
        const block = padded_ct[i..][0..BLOCK_SIZE];
        var j: usize = 0;
        while (j < flag_enc.len) : (j += BLOCK_SIZE) {
            const flag_block = flag_enc[j..][0..BLOCK_SIZE];
            if (std.mem.eql(u8, block, flag_block)) {
                return false;
            }
        }
    }
    return true;
}

fn f1(hex: []const u8, allocator: std.mem.Allocator) ![]u8 {
    if (hex.len % 2 != 0) {
        return error.InvalidHexLength;
    }
    const bytes = try allocator.alloc(u8, hex.len / 2);
    for (0..bytes.len) |i| {
        bytes[i] = std.fmt.parseInt(u8, hex[i * 2 ..][0..2], 16) catch {
            allocator.free(bytes);
            return error.InvalidHexChar;
        };
    }
    return bytes;
}

fn f2(bytes: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const hex = try allocator.alloc(u8, bytes.len * 2);
    for (bytes, 0..) |b, i| {
        _ = std.fmt.bufPrint(hex[i * 2 ..][0..2], "{x:0>2}", .{b}) catch unreachable;
    }
    return hex;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    const flag = std.fs.cwd().readFileAlloc(allocator, "flag", 1024) catch |err| {
        try stdout.print("Error reading flag file: {}\n", .{err});
        return;
    };
    defer allocator.free(flag);

    var key: [BLOCK_SIZE]u8 = undefined;
    var iv: [BLOCK_SIZE]u8 = undefined;
    crypto.random.bytes(&key);
    crypto.random.bytes(&iv);

    const padded_flag = try pad(flag, allocator);
    defer allocator.free(padded_flag);

    const flag_enc = try sch3m3Encrypt(padded_flag, key, iv, allocator);
    defer allocator.free(flag_enc);

    const banner = std.fs.cwd().readFileAlloc(allocator, "banner", 2048) catch |err| {
        try stdout.print("Error reading banner file: {}\n", .{err});
        return;
    };
    defer allocator.free(banner);

    try stdout.print("{s}", .{banner});

    try stdout.print("Welcome to GIZSEA server\n", .{});

    while (true) {
        try stdout.print("[1] Encrypt\n", .{});
        try stdout.print("[2] Decrypt\n", .{});
        try stdout.print("[3] Get Flag\n", .{});

        var choice_buf: [64]u8 = undefined;
        const choice_line = stdin.readUntilDelimiter(&choice_buf, '\n') catch break;
        const choice = std.mem.trim(u8, choice_line, " \t\r\n");

        if (std.mem.eql(u8, choice, "1")) {
            try stdout.print("Input plaintext (hex): ", .{});

            var input_buf: [4096]u8 = undefined;
            const input_line = stdin.readUntilDelimiter(&input_buf, '\n') catch break;
            const hex_input = std.mem.trim(u8, input_line, " \t\r\n");

            const pt = f1(hex_input, allocator) catch {
                try stdout.print("Invalid hex input\n", .{});
                continue;
            };
            defer allocator.free(pt);

            const ct = sch3m3Encrypt(pt, key, iv, allocator) catch {
                try stdout.print("Encryption error\n", .{});
                continue;
            };
            defer allocator.free(ct);

            const hex_out = try f2(ct, allocator);
            defer allocator.free(hex_out);
            try stdout.print("{s}\n", .{hex_out});
        } else if (std.mem.eql(u8, choice, "2")) {
            try stdout.print("Input ciphertext (hex): ", .{});

            var input_buf: [4096]u8 = undefined;
            const input_line = stdin.readUntilDelimiter(&input_buf, '\n') catch break;
            const hex_input = std.mem.trim(u8, input_line, " \t\r\n");

            const ct = f1(hex_input, allocator) catch {
                try stdout.print("Invalid hex input\n", .{});
                continue;
            };
            defer allocator.free(ct);

            const valid = isValid(ct, flag_enc, allocator) catch {
                try stdout.print("Validation error\n", .{});
                continue;
            };

            if (valid) {
                const pt = sch3m3Decrypt(ct, key, iv, allocator) catch {
                    try stdout.print("Decryption error\n", .{});
                    continue;
                };
                defer allocator.free(pt);

                const hex_out = try f2(pt, allocator);
                defer allocator.free(hex_out);
                try stdout.print("{s}\n", .{hex_out});
            } else {
                try stdout.print("Nope!\n", .{});
            }
        } else if (std.mem.eql(u8, choice, "3")) {
            const hex_flag = try f2(flag_enc, allocator);
            defer allocator.free(hex_flag);
            try stdout.print("flag = {s}\n", .{hex_flag});
        } else {
            try stdout.print("Nope!\n", .{});
        }
    }
}
