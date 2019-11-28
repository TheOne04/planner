public class Services.Notifications : GLib.Object {
    public signal void send_notification (int type, string message);

    private string MOVE_TEMPLATE = "<b>%s</b> moved to <b>%s</b>";
    private string DELETE_TEMPLATE = "(%i) %s deleted";

    construct {
        init_server ();

        Application.database.show_toast_delete.connect ((count) => {
            string t = _("task");
            if (count > 1) {
                t = _("tasks");
            }

            send_notification (
                1,
                DELETE_TEMPLATE.printf (count, t)
            );
        });

        Application.database.item_moved.connect ((item) => {
            Idle.add (() => {
                send_notification (
                    0, 
                    MOVE_TEMPLATE.printf (
                        item.content, 
                        Application.database.get_project_by_id (item.project_id).name
                    )
                );

                return false;
            });
        });

        Application.database.section_moved.connect ((section) => {
            Idle.add (() => {
                send_notification (
                    0, 
                    MOVE_TEMPLATE.printf (
                        section.name, 
                        Application.database.get_project_by_id (section.project_id).name
                    )
                );

                return false;
            });
        });
    }

    private void init_server () {
        Timeout.add_seconds (1 * 60, () => {
            foreach (var reminder in Application.database.get_reminders ()) {
                if (reminder.datetime.compare (new GLib.DateTime.now_local ()) <= 0) {
                    var notification = new Notification (reminder.project_name);
                    notification.set_body (reminder.content);
                    notification.set_icon (new ThemedIcon ("com.github.alainm23.planner"));
                    notification.set_priority (GLib.NotificationPriority.URGENT);

                    Application.instance.send_notification ("com.github.alainm23.planner", notification);
                    Application.database.delete_reminder (reminder.id);
                }
            }

            return true;
        });
    }
}