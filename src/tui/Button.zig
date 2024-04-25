const std = @import("std");
const tp = @import("thespian");

const Plane = @import("renderer").Plane;
const key = @import("renderer").input.key;
const event_type = @import("renderer").input.event_type;

const Widget = @import("Widget.zig");
const command = @import("command.zig");
const tui = @import("tui.zig");

pub fn Options(context: type) type {
    return struct {
        label: []const u8 = "button",
        pos: Widget.Box = .{ .y = 0, .x = 0, .w = 8, .h = 1 },
        ctx: Context,

        on_click: *const fn (ctx: *context, button: *State(Context)) void = do_nothing,
        on_click2: *const fn (ctx: *context, button: *State(Context)) void = do_nothing,
        on_click3: *const fn (ctx: *context, button: *State(Context)) void = do_nothing,
        on_render: *const fn (ctx: *context, button: *State(Context), theme: *const Widget.Theme) bool = on_render_default,
        on_layout: *const fn (ctx: *context, button: *State(Context)) Widget.Layout = on_layout_default,
        on_receive: *const fn (ctx: *context, button: *State(Context), from: tp.pid_ref, m: tp.message) error{Exit}!bool = on_receive_default,

        pub const Context = context;
        pub fn do_nothing(_: *context, _: *State(Context)) void {}

        pub fn on_render_default(_: *context, self: *State(Context), theme: *const Widget.Theme) bool {
            self.plane.set_base_style(" ", if (self.active) theme.scrollbar_active else if (self.hover) theme.scrollbar_hover else theme.scrollbar);
            self.plane.erase();
            self.plane.home();
            _ = self.plane.print(" {s} ", .{self.opts.label}) catch {};
            return false;
        }

        pub fn on_layout_default(_: *context, self: *State(Context)) Widget.Layout {
            return .{ .static = self.opts.label.len + 2 };
        }

        pub fn on_receive_default(_: *context, _: *State(Context), _: tp.pid_ref, _: tp.message) error{Exit}!bool {
            return false;
        }
    };
}

pub fn create(ctx_type: type, a: std.mem.Allocator, parent: Plane, opts: Options(ctx_type)) !*State(ctx_type) {
    const Self = State(ctx_type);
    const self = try a.create(Self);
    var n = try Plane.init(&opts.pos.opts(@typeName(Self)), parent);
    errdefer n.deinit();
    self.* = .{
        .a = a,
        .parent = parent,
        .plane = n,
        .opts = opts,
    };
    self.opts.label = try self.a.dupe(u8, opts.label);
    return self;
}

pub fn create_widget(ctx_type: type, a: std.mem.Allocator, parent: Plane, opts: Options(ctx_type)) !Widget {
    return Widget.to(try create(ctx_type, a, parent, opts));
}

pub fn State(ctx_type: type) type {
    return struct {
        a: std.mem.Allocator,
        parent: Plane,
        plane: Plane,
        active: bool = false,
        hover: bool = false,
        opts: Options(ctx_type),

        const Self = @This();
        pub const Context = ctx_type;

        pub fn deinit(self: *Self, a: std.mem.Allocator) void {
            self.a.free(self.opts.label);
            self.plane.deinit();
            a.destroy(self);
        }

        pub fn layout(self: *Self) Widget.Layout {
            return self.opts.on_layout(&self.opts.ctx, self);
        }

        pub fn render(self: *Self, theme: *const Widget.Theme) bool {
            return self.opts.on_render(&self.opts.ctx, self, theme);
        }

        pub fn receive(self: *Self, from: tp.pid_ref, m: tp.message) error{Exit}!bool {
            var btn: u32 = 0;
            if (try m.match(.{ "B", event_type.PRESS, tp.extract(&btn), tp.any, tp.any, tp.any, tp.any, tp.any })) {
                self.active = true;
                tui.need_render();
                return true;
            } else if (try m.match(.{ "B", event_type.RELEASE, tp.extract(&btn), tp.any, tp.any, tp.any, tp.any, tp.any })) {
                self.call_click_handler(btn);
                self.active = false;
                tui.need_render();
                return true;
            } else if (try m.match(.{ "D", event_type.RELEASE, tp.extract(&btn), tp.any, tp.any, tp.any, tp.any, tp.any })) {
                self.call_click_handler(btn);
                self.active = false;
                tui.need_render();
                return true;
            } else if (try m.match(.{ "H", tp.extract(&self.hover) })) {
                tui.renderer.request_mouse_cursor_pointer(self.hover);
                tui.need_render();
                return true;
            }
            return self.opts.on_receive(&self.opts.ctx, self, from, m);
        }

        fn call_click_handler(self: *Self, btn: u32) void {
            if (!self.hover) return;
            switch (btn) {
                key.BUTTON1 => self.opts.on_click(&self.opts.ctx, self),
                key.BUTTON2 => self.opts.on_click2(&self.opts.ctx, self),
                key.BUTTON3 => self.opts.on_click3(&self.opts.ctx, self),
                else => {},
            }
        }
    };
}
