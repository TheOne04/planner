public class Dialogs.ProjectPicker.SectionPickerRow : Gtk.ListBoxRow {
    public Objects.Section section { get; construct; }
    
    private Gtk.Label name_label;
    private Gtk.Revealer main_revealer;
    private Widgets.IconColorProject icon_project;

    public SectionPickerRow (Objects.Section section) {
        Object (
            section: section
        );
    }

    construct {
        add_css_class ("selectable-item");
        add_css_class ("transition");

        name_label = new Gtk.Label (null);
        name_label.valign = Gtk.Align.CENTER;
        name_label.ellipsize = Pango.EllipsizeMode.END;

        var selected_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("emblem-ok-symbolic"),
            pixel_size = 16,
            hexpand = true,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.END,
            margin_end = 3
        };

        selected_icon.add_css_class ("color-primary");

        var selected_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };

        selected_revealer.child = selected_icon;

        var content_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin_top = 6,
            margin_start = 6,
            margin_end = 6,
            margin_bottom = 6
        };
        content_box.append (name_label);
        content_box.append (selected_revealer);

        main_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        };

        main_revealer.child = content_box;

        child = main_revealer;
        
        update_request ();

        Timeout.add (main_revealer.transition_duration, () => {
            main_revealer.reveal_child = true;
            return GLib.Source.REMOVE;
        });

        var select_gesture = new Gtk.GestureClick ();
        add_controller (select_gesture);

        select_gesture.pressed.connect (() => {
            Planner.event_bus.section_picker_changed (section.id);
        });

        Planner.event_bus.section_picker_changed.connect ((type, id) => {
            selected_revealer.reveal_child = section.id == id;
        });
    }

    public void update_request () {
        name_label.label = section.name;
    }
}