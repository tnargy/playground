const std = @import("std");
const net: type = std.net;
const posix = std.posix;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var pool: std.Thread.Pool = undefined;
    try std.Thread.Pool.init(&pool, .{.allocator = allocator, .n_jobs = 64});

    const addr = net.Address.initIp4(.{ 0, 0, 0, 0 }, 8080);
    const lsnr = try posix.socket(addr.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
    defer posix.close(lsnr);

    try posix.setsockopt(lsnr, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(lsnr, &addr.any, addr.getOsSockLen());
    try posix.listen(lsnr, 128);

    std.debug.print("Server started...\n", .{});
    while (true) {
        var client_address: net.Address = undefined;
        var client_address_len: posix.socklen_t = @sizeOf(net.Address);

        const socket = posix.accept(lsnr, &client_address.any, &client_address_len, 0) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            continue;
        };
        const client = Client{ .socket = socket, .address = client_address };
        try pool.spawn(Client.handle, .{client});
    }
}

const Client = struct {
    socket: posix.socket_t,
    address: std.net.Address,

    fn handle(self: Client) void {
        self._handle() catch |err| switch (err) {
            error.Closed => {},
            else => std.debug.print("[{any}] client handle error: {}\n", .{self.address, err}),
        };
    }

    fn _handle(self: Client) !void {
        const socket = self.socket;
        defer posix.close(socket);

        std.debug.print("{} connected\n", .{self.address});

        const timeout = posix.timeval{ .tv_sec = 5, .tv_usec = 0 };
        try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.RCVTIMEO, &std.mem.toBytes(timeout));
        try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.SNDTIMEO, &std.mem.toBytes(timeout));

        var buf: [1 << 10]u8 = undefined;
        const stream = std.net.Stream{ .handle = socket };
        while (true) {
            const read = stream.read(&buf) catch |err| {
                std.debug.print("error read: {}\n", .{err});
                continue;
            };
            _ = try stream.write(buf[0..read]);
            if (read == 0) break;
        }
    }
};
