const std = @import("std");
const Allocator = std.mem.Allocator;

const Plane = @import("renderer").Plane;
const style = @import("renderer").style;
const styles = @import("renderer").styles;
const command = @import("command");
const EventHandler = @import("EventHandler");

const Widget = @import("../Widget.zig");
const Button = @import("../Button.zig");
const tui = @import("../tui.zig");
const CreateError = @import("widget.zig").CreateError;

pub fn create(allocator: Allocator, parent: Plane, event_handler: ?EventHandler, _: ?[]const u8) CreateError!Widget {
    return Button.create_widget(void, allocator, parent, .{
        .ctx = {},
        .label = tui.get_mode(),
        .on_click = on_click,
        .on_click2 = toggle_panel,
        .on_click3 = toggle_panel,
        .on_layout = layout,
        .on_render = render,
        .on_event = event_handler,
    });
}

pub fn layout(_: *void, btn: *Button.State(void)) Widget.Layout {
    const name = btn.plane.egc_chunk_width(tui.get_mode(), 0, 1);
    const logo = if (is_mini_mode() or is_overlay_mode()) 1 else btn.plane.egc_chunk_width(left ++ symbol ++ right, 0, 1);
    const padding: usize = 2;
    const minimode_sep: usize = if (is_mini_mode()) 1 else 0;
    return .{ .static = logo + name + padding + minimode_sep };
}

fn is_mini_mode() bool {
    return tui.mini_mode() != null;
}

fn is_overlay_mode() bool {
    return tui.input_mode_outer() != null;
}

pub fn render(_: *void, self: *Button.State(void), theme: *const Widget.Theme) bool {
    const style_base = theme.statusbar;
    const style_label = if (self.active) theme.editor_cursor else if (self.hover) theme.editor_selection else theme.statusbar_hover;
    self.plane.set_base_style(theme.editor);
    self.plane.erase();
    self.plane.home();
    self.plane.set_style(style_base);
    self.plane.fill(" ");
    self.plane.home();
    self.plane.set_style(style_label);
    self.plane.fill(" ");
    self.plane.home();
    self.plane.on_styles(styles.bold);
    var buf: [31:0]u8 = undefined;
    if (!is_mini_mode() and !is_overlay_mode()) {
        render_logo(self, theme, style_label);
    } else {
        _ = self.plane.putstr("  ") catch {};
    }
    self.plane.set_style(style_label);
    self.plane.on_styles(styles.bold);
    _ = self.plane.putstr(std.fmt.bufPrintZ(&buf, "{s} ", .{tui.get_mode()}) catch return false) catch {};
    if (is_mini_mode())
        render_separator(self, theme);
    return false;
}

fn render_separator(self: *Button.State(void), theme: *const Widget.Theme) void {
    self.plane.reverse_style();
    self.plane.set_base_style(.{ .bg = theme.editor.bg });
    if (theme.statusbar.bg) |bg| self.plane.set_style(.{ .bg = bg });
    _ = self.plane.putstr("") catch {};
}

const left = " ";
const symbol = "󱞏";
const right = " ";

fn render_logo(self: *Button.State(void), theme: *const Widget.Theme, base_style: Widget.Theme.Style) void {
    // const style_symbol: Widget.Theme.Style = if (tui.find_scope_style(theme, "number")) |sty| .{ .fg = sty.style.fg, .bg = base_style.bg, .fs = base_style.fs } else base_style;
    const style_symbol = if (self.active) theme.editor_cursor else if (self.hover) theme.editor_selection else theme.statusbar_hover;
    const style_braces: Widget.Theme.Style = if (tui.find_scope_style(theme, "punctuation")) |sty| .{ .fg = sty.style.fg, .bg = base_style.bg, .fs = base_style.fs } else base_style;
    if (left.len > 0) {
        self.plane.set_style(style_braces);
        _ = self.plane.putstr(" " ++ left) catch {};
    }
    self.plane.set_style(style_symbol);
    _ = self.plane.putstr(symbol) catch {};
    if (right.len > 0) {
        self.plane.set_style(style_braces);
        _ = self.plane.putstr(right) catch {};
    }
}

fn on_click(_: *void, _: *Button.State(void)) void {
    if (is_mini_mode()) {
        command.executeName("exit_mini_mode", .{}) catch {};
    } else if (is_overlay_mode()) {
        command.executeName("exit_overlay_mode", .{}) catch {};
    } else {
        command.executeName("open_command_palette", .{}) catch {};
    }
}

fn toggle_panel(_: *void, _: *Button.State(void)) void {
    command.executeName("toggle_panel", .{}) catch {};
}
