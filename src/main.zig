const std = @import("std");
const builtin = @import("builtin");
const cl = @import("colours.zig");

const print = std.debug.print;

//createStr template: https://profiles.dnull.xyz/update?handle=
//                    handle
//                    &image_ref=60bd3bc7-c9cb-433e-90a9-6e4e44c4a846

const Colour = cl.Colour;

fn changeID(url: []const u8, bearer: []const u8, client: *std.http.Client) std.http.Status {
    const uri = std.Uri.parse(url) catch {
        return .bad_request;
    };

    const fopt: std.http.Client.FetchOptions = .{ .method = .POST, .location = .{ .uri = uri }, .headers = .{ .authorization = .{ .override = bearer } }, .payload = "" };

    const res = client.fetch(fopt) catch {
        return .bad_request;
    };
    return res.status;
}

fn soCalledWhileLoop(url: []const u8, handle: []const u8, bearer: []const u8, io: *const std.Io, alloc: std.mem.Allocator) void {
    var client = std.http.Client{ .allocator = alloc, .io = io.* };
    defer client.deinit();
    var state: u3 = 1;
    print("Sniping... ({s})", .{handle});
    sniper: while (true) {
        const res = changeID(url, bearer, &client);
        switch (res) {
            .ok => {
                print("\n{s}Sniped ({s})!{s}\n", .{ Colour.b_green, handle, Colour.reset });
                break :sniper;
            },
            .teapot => {
                switch (state) {
                    1 => {
                        print("\rSniping.{s}   ({s}){s}", .{ Colour.magenta, handle, Colour.reset });
                        state += 1;
                    },
                    2 => {
                        print("\rSniping..{s}  ({s}){s}", .{ Colour.cyan, handle, Colour.reset });
                        state += 1;
                    },
                    3 => {
                        print("\rSniping...{s} ({s}){s}", .{ Colour.yellow, handle, Colour.reset });
                        state += 1;
                    },
                    4 => {
                        print("\rSniping....{s}({s}){s}", .{ Colour.green, handle, Colour.reset });
                        state = 1;
                    },
                    else => {},
                }
            },
            else => {
                print("\n{s}API returned something... completely weird?? (status: {d}){s}\n", .{ Colour.b_red, res, Colour.reset });
                break :sniper;
            },
        }
        io.sleep(std.Io.Duration.fromMilliseconds(100), .awake) catch {
            print("Error within io.sleep", .{});
            break :sniper;
        };
    }
}

pub fn main(init: std.process.Init) !void {
    if (builtin.os.tag == .windows) {
        print("Windows user detected!!! Output may not work as expected...\n", .{});
    }
    if (builtin.mode != .ReleaseFast) {
        print("{s}{s}WARNING, I would prefer if you used --release=fast mode in your build command as it helps code run quicker!!{s}\n", .{ Colour.b_yellow, Colour.bold, Colour.reset });
    }

    const alloc = init.gpa;
    const io = init.io;

    const handle = ""; //your nullsid here (the one u r going to snipe)
    const bearerstr = ""; //your token here

    const strlist = &[_][]const u8{
        "https://profiles.dnull.xyz/update?handle=",
        handle,
        "&image_ref=60bd3bc7-c9cb-433e-90a9-6e4e44c4a846",
    };

    const bearerlist = &[_][]const u8{
        "Bearer ",
        bearerstr,
    };

    const url = try std.mem.concat(alloc, u8, strlist);
    const bearer = try std.mem.concat(alloc, u8, bearerlist);
    defer alloc.free(url);
    defer alloc.free(bearer);

    {
        print("Encountering issues? Text @denysdt on tg or dc, maybe I'll look into it idk\n\n", .{});
        const thr = try std.Thread.spawn(.{}, soCalledWhileLoop, .{ url, handle, bearer, &io, alloc });
        defer thr.join();

        print("{s}Started the loop...{s}\n", .{ Colour.cyan, Colour.reset });
    }

    //std.debug.print("status={d}\n", .{res});
}
