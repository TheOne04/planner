/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class Dialogs.Project : Adw.Window {
    public Objects.Project project { get; construct; }

    private Widgets.EntryRow name_entry;
    private Widgets.ColorPickerRow color_picker_row;
    private Widgets.LoadingButton submit_button;
    private Widgets.SwitchRow emoji_switch;
    private Gtk.Label emoji_label;

    public bool is_creating {
        get {
            return project.id == Constants.INACTIVE;
        }
    }

    public Project.new () {
        var project = new Objects.Project ();
        project.color = Util.get_default ().get_random_color ();
        project.emoji = "🚀️";
        project.id = Constants.INACTIVE;

        Object (
            project: project,
            deletable: true,
            resizable: true,
            modal: true,
            title: _("New Project"),
            width_request: 320,
            height_request: 400,
            transient_for: (Gtk.Window) Planner.instance.main_window
        );
    }

    public Project (Objects.Project project) {
        Object (
            project: project,
            deletable: true,
            resizable: true,
            modal: true,
            title: _("Edit Project"),
            width_request: 320,
            height_request: 400,
            transient_for: (Gtk.Window) Planner.instance.main_window
        );
    }

    construct {
        var headerbar = new Adw.HeaderBar ();
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        emoji_label = new Gtk.Label (project.emoji);

        var progress_bar = new Widgets.CircularProgressBar (32);
        progress_bar.percentage = 0.64;
        progress_bar.color = project.color;

        var emoji_color_stack = new Gtk.Stack () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };

        emoji_color_stack.add_named (emoji_label, "emoji");
        emoji_color_stack.add_named (progress_bar, "color");

        var emoji_picker_button = new Gtk.Button () {
            hexpand = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            can_focus = false,
            height_request = 64,
            width_request = 64,
            margin_top = 6
        };

        var emoji_chooser = new Gtk.EmojiChooser () {
            has_arrow = true
        };

        emoji_chooser.set_parent (emoji_picker_button);

        emoji_picker_button.child = emoji_color_stack;
        
        emoji_picker_button.add_css_class (Granite.STYLE_CLASS_H2_LABEL);
        emoji_picker_button.add_css_class ("button-emoji-picker");

        emoji_switch = new Widgets.SwitchRow (_("Use Emoji"), "emoji-happy", "none");
        emoji_switch.active = project.icon_style == ProjectIconStyle.EMOJI;

        name_entry = new Widgets.EntryRow ();
        name_entry.entry.text = project.name;

        var name_emoji_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
            margin_top = 24,
            margin_end = 12,
            margin_start = 12
        };

        name_emoji_box.add_css_class ("card");
        name_emoji_box.add_css_class ("padding-6");

        name_emoji_box.append (name_entry);
        name_emoji_box.append (emoji_switch);

        color_picker_row = new Widgets.ColorPickerRow ("none");
        color_picker_row.selected = project.color;

        var color_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
            margin_top = 24,
            margin_end = 12,
            margin_start = 12,
            margin_bottom = 3
        };

        color_box.add_css_class ("card");
        color_box.add_css_class ("padding-6");

        color_box.append (color_picker_row);

        var color_box_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
            reveal_child = project.icon_style == ProjectIconStyle.PROGRESS
        };

        color_box_revealer.child = color_box;

        submit_button = new Widgets.LoadingButton.with_label (is_creating ? _("Add project") : _("Update project")) {
            vexpand = true,
            hexpand = true,
            margin_bottom = 12,
            margin_end = 12,
            margin_start = 12,
            margin_top = 12,
            valign = Gtk.Align.END
        };

        submit_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        
        content_box.append (headerbar);
        content_box.append (emoji_picker_button);
        content_box.append (name_emoji_box);
        content_box.append (color_box_revealer);
        content_box.append (submit_button);

        content = content_box;
        name_entry.grab_focus ();

        Timeout.add (emoji_color_stack.transition_duration, () => {
            if (project.icon_style == ProjectIconStyle.PROGRESS) {
                emoji_color_stack.visible_child_name = "color";
            } else {
                emoji_color_stack.visible_child_name = "emoji";
            }
            
            return GLib.Source.REMOVE;
        });

        submit_button.clicked.connect (add_update_project);

        emoji_chooser.emoji_picked.connect((emoji) => {
            emoji_label.label = emoji;
        });

        emoji_switch.activated.connect ((active) => {
            if (active) {
                color_box_revealer.reveal_child = false;
                emoji_color_stack.visible_child_name = "emoji";
            } else {
                color_box_revealer.reveal_child = true;
                emoji_color_stack.visible_child_name = "color";
            }
        });

        color_picker_row.color_changed.connect ((color) => {
            progress_bar.color = color;
        });

        emoji_picker_button.clicked.connect (() => {
            if (emoji_switch.active) {
                emoji_chooser.popup ();
            }
        });
    }

    private void add_update_project () {
        if (!Util.get_default ().is_input_valid (name_entry.entry)) {
            hide_destroy ();
            return;
        }

        project.name = name_entry.entry.text;
        project.color = color_picker_row.selected;
        project.icon_style = emoji_switch.active ? ProjectIconStyle.EMOJI : ProjectIconStyle.PROGRESS;
        project.emoji = emoji_label.label;

        if (!is_creating) {
            submit_button.is_loading = true;
            Services.Database.get_default().update_project (project);
            if (project.todoist) {
                //  Planner.todoist.update.begin (project, (obj, res) => {
                //      Planner.todoist.update.end (res);
                //      submit_button.is_loading = false;
                //      hide_destroy ();
                //  });
            } else {
                hide_destroy ();
            }
        } else {
            project.id = Util.get_default ().generate_id ();

            Services.Database.get_default().insert_project (project);
            // Planner.event_bus.pane_selected (PaneType.PROJECT, project.id_string);
            hide_destroy ();
        }
    }

    public void hide_destroy () {
        hide ();

        Timeout.add (500, () => {
            destroy ();
            return GLib.Source.REMOVE;
        });
    }
}