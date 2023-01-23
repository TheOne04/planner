public class Widgets.ScheduleButton : Gtk.Button {
    private Gtk.Label due_label;

    private Gtk.Label repeat_label;
    private Gtk.Revealer repeat_revealer;
    
    private Gtk.Box schedule_box;
    private Widgets.DynamicIcon due_image;

    private Widgets.DateTimePicker.DateTimePicker datetime_picker = null;
    public GLib.DateTime datetime { get; set; }

    public signal void date_changed (GLib.DateTime? date);

    public ScheduleButton () {
        Object (
            can_focus: false,
            valign: Gtk.Align.CENTER,
            halign: Gtk.Align.CENTER,
            tooltip_text: _("Schedule")
        );
    }

    construct {
        add_css_class (Granite.STYLE_CLASS_FLAT);
        add_css_class ("p3");

        due_image = new Widgets.DynamicIcon ();
        due_image.update_icon_name ("planner-calendar");
        due_image.size = 19;        

        due_label = new Gtk.Label (_("Schedule")) {
            xalign = 0
        };

        repeat_label = new Gtk.Label (null) {
            xalign = 0
        };

        repeat_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        repeat_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        repeat_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT
        };
        repeat_revealer.child = repeat_label;

        schedule_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 3);
        schedule_box.append (due_image);
        schedule_box.append (due_label);
        schedule_box.append (repeat_revealer);

        set_child (schedule_box);

        var gesture = new Gtk.GestureClick ();
        gesture.set_button (1);
        add_controller (gesture);

        gesture.pressed.connect ((n_press, x, y) => {
            gesture.set_state (Gtk.EventSequenceState.CLAIMED);
            open_datetime_picker ();
        });
    }

    private void open_datetime_picker () {
        if (datetime_picker == null) {
            datetime_picker = new Widgets.DateTimePicker.DateTimePicker ();
            datetime_picker.set_parent (this);
                    
            datetime_picker.date_changed.connect (() => {
                date_changed (datetime_picker.datetime);
            });
        }

        datetime_picker.visible_no_date = false;
        if (datetime != null) {
            datetime_picker.visible_no_date = true;
            datetime_picker.datetime = datetime;
        }

        datetime_picker.popup ();
    }

    public void update_from_item (Objects.Item item) {
        due_label.label = _("Schedule");
        repeat_label.label = "";
        repeat_revealer.reveal_child = false;

        due_image.update_icon_name ("planner-calendar");
        datetime = null;

        if (item.has_due) {
            datetime = new GLib.DateTime.local (
                item.due.datetime.get_year (),
                item.due.datetime.get_month (),
                item.due.datetime.get_day_of_month (),
                item.due.datetime.get_hour (),
                item.due.datetime.get_minute (),
                item.due.datetime.get_second ()
            );

            if (item.due.is_recurring) {
                due_image.update_icon_name ("planner-repeat");
                due_label.label = item.due.to_friendly_string ();
                repeat_label.label = "- %s".printf (
                    Util.get_default ().next_x_recurrency (datetime, item.due)
                );
                repeat_revealer.reveal_child = true;
            } else {  
                due_label.label = Util.get_default ().get_relative_date_from_date (item.due.datetime);
    
                if (Util.get_default ().is_today (item.due.datetime)) {
                    due_image.update_icon_name ("planner-today");
                } else if (Util.get_default ().is_overdue (item.due.datetime)) {

                } else {
                    due_image.update_icon_name ("planner-scheduled");
                }
            }
        }
    }
}