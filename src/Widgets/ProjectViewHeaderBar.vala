public class Widgets.ProjectViewHeaderBar : Gtk.Grid {
    public Objects.BaseObject view { get; set; }

    public ProjectViewHeaderBar () {
        Object (
            valign: Gtk.Align.CENTER
        );
    }   

    construct {
        var circular_progress_bar = new Widgets.CircularProgressBar (8);

        var emoji_label = new Gtk.Label (null) {
            halign = Gtk.Align.CENTER
        };

        emoji_label.get_style_context ().add_class ("header-title");

        var progress_emoji_stack = new Gtk.Stack ();
        progress_emoji_stack.add_named (circular_progress_bar, "progress");
        progress_emoji_stack.add_named (emoji_label, "label");

        var inbox_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("planner-inbox"),
            pixel_size = 24
        };

        var icon_progress_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };

        icon_progress_stack.add_named (progress_emoji_stack, "color");
        icon_progress_stack.add_named (inbox_icon, "icon");

        var title_label = new Gtk.Label (null);
        title_label.add_css_class ("font-bold");

        var content_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            hexpand = true
        };

        content_box.append (icon_progress_stack);
        content_box.append (title_label);

        var content_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };

        content_revealer.child = content_box;

        attach (content_revealer, 0, 0);

        notify["view"].connect (() => {
            content_revealer.reveal_child = false;

            if (view is Objects.Project) {
                var project = ((Objects.Project) view);
                title_label.label = project.name;

                icon_progress_stack.visible_child_name = project.inbox_project ? "icon" : "color";
                inbox_icon.gicon = new ThemedIcon ("planner-inbox");

                if (project.icon_style == ProjectIconStyle.PROGRESS) {
                    progress_emoji_stack.visible_child_name = "progress";
                } else {
                    progress_emoji_stack.visible_child_name = "label";
                }

                circular_progress_bar.percentage = project.percentage;
                circular_progress_bar.color = project.color;
                emoji_label.label = project.emoji;

                project.project_count_updated.connect (() => {
                    circular_progress_bar.percentage = project.percentage;
                });
        
                project.updated.connect (() => {
                    title_label.label = project.name;
                    
                    circular_progress_bar.color = Util.get_default ().get_color (project.color);
                    circular_progress_bar.percentage = project.percentage;
                    
                    emoji_label.label = project.emoji;
                    if (project.icon_style == ProjectIconStyle.PROGRESS) {
                        progress_emoji_stack.visible_child_name = "progress";
                    } else {
                        progress_emoji_stack.visible_child_name = "label";
                    }
                });
            } else if (view is Objects.Today) {
                title_label.label = _("Today");
                icon_progress_stack.visible_child_name = "icon";
                inbox_icon.gicon = new ThemedIcon ("planner-today");
            } else if (view is Objects.Scheduled) {
                title_label.label = _("Scheduled");
                icon_progress_stack.visible_child_name = "icon";
                inbox_icon.gicon = new ThemedIcon ("planner-scheduled");
            } else if (view is Objects.Pinboard) {
                title_label.label = _("Pinboard");
                icon_progress_stack.visible_child_name = "icon";
                inbox_icon.gicon = new ThemedIcon ("planner-pin-tack");
            } else if (view is Objects.Label) {
                title_label.label = ((Objects.Label) view).name;
            }
        });

        Planner.event_bus.view_header.connect ((reveal_child) => {
            content_revealer.reveal_child = reveal_child;
        });
    }
}