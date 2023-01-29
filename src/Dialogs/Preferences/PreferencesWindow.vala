public class Dialogs.Preferences.PreferencesWindow : Adw.PreferencesWindow {
    
    public PreferencesWindow () {
        Object (
            transient_for: (Gtk.Window) Planner.instance.main_window,
            deletable: true,
            destroy_with_parent: true,
            modal: true,
            height_request: 500,
            width_request: 360
        );
    }

    construct {
        add (get_general_page ());
        add (get_accounts_page ());
    }

    private Adw.PreferencesPage get_general_page () {
        var page = new Adw.PreferencesPage ();
        page.title = _("General");
        page.name = "general";
        page.icon_name = "applications-system-symbolic";

        build_appearance (page);

        var general_group = new Adw.PreferencesGroup ();
        general_group.title = _("General");

        var sort_projects_model = new Gtk.StringList (null);
        sort_projects_model.append (_("Alphabetically"));
        sort_projects_model.append (_("Custom sort order"));

        var sort_projects_row = new Adw.ComboRow ();
        sort_projects_row.title = _("Sort projects");
        sort_projects_row.model = sort_projects_model;
        sort_projects_row.selected = Planner.settings.get_enum ("projects-sort-by");

        general_group.add (sort_projects_row);

        var sort_order_projects_model = new Gtk.StringList (null);
        sort_order_projects_model.append (_("Ascending"));
        sort_order_projects_model.append (_("Descending"));

        var sort_order_projects_row = new Adw.ComboRow ();
        sort_order_projects_row.title = _("Sort by");
        sort_order_projects_row.model = sort_order_projects_model;
        sort_order_projects_row.selected = Planner.settings.get_enum ("projects-ordered");

        general_group.add (sort_order_projects_row);

        var de_group = new Adw.PreferencesGroup ();
        de_group.title = _("DE Integration");

        var run_background_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Planner.settings.get_boolean ("run-in-background")
        };

        var run_background_row = new Adw.ActionRow ();
        run_background_row.title = _("Run in background");
        run_background_row.set_activatable_widget (run_background_switch);
        run_background_row.add_suffix (run_background_switch);

        de_group.add (run_background_row);

        var calendar_events_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Planner.settings.get_boolean ("calendar-enabled")
        };

        var calendar_events_row = new Adw.ActionRow ();
        calendar_events_row.title = _("Calendar Events");
        calendar_events_row.set_activatable_widget (calendar_events_switch);
        calendar_events_row.add_suffix (calendar_events_switch);

        de_group.add (calendar_events_row);

        var datetime_group = new Adw.PreferencesGroup ();
        datetime_group.title = _("Date and Time");

        var clock_format_model = new Gtk.StringList (null);
        clock_format_model.append (_("24h"));
        clock_format_model.append (_("12h"));

        var clock_format_row = new Adw.ComboRow ();
        clock_format_row.title = _("Clock Format");
        clock_format_row.model = clock_format_model;
        clock_format_row.selected = Planner.settings.get_enum ("clock-format");

        datetime_group.add (clock_format_row);

        var start_week_model = new Gtk.StringList (null);
        start_week_model.append (_("Sunday"));
        start_week_model.append (_("Monday"));

        var start_week_row = new Adw.ComboRow ();
        start_week_row.title = _("Start of the week");
        start_week_row.model = start_week_model;
        start_week_row.selected = Planner.settings.get_enum ("start-week");

        datetime_group.add (start_week_row);

        var tasks_group = new Adw.PreferencesGroup ();
        tasks_group.title = _("Task settings");

        var complete_tasks_model = new Gtk.StringList (null);
        complete_tasks_model.append (_("Instantly"));
        complete_tasks_model.append (_("Wait 2500 milliseconds"));

        var complete_tasks_row = new Adw.ComboRow ();
        complete_tasks_row.title = _("Complete task");
        complete_tasks_row.model = complete_tasks_model;
        complete_tasks_row.selected = Planner.settings.get_enum ("complete-task");

        tasks_group.add (complete_tasks_row);

        var default_priority_model = new Gtk.StringList (null);
        default_priority_model.append (_("Priority 1"));
        default_priority_model.append (_("Priority 2"));
        default_priority_model.append (_("Priority 3"));
        default_priority_model.append (_("None"));

        var default_priority_row = new Adw.ComboRow ();
        default_priority_row.title = _("Default priority");
        default_priority_row.model = default_priority_model;
        default_priority_row.selected = Planner.settings.get_enum ("default-priority");

        tasks_group.add (default_priority_row);

        var description_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Planner.settings.get_boolean ("description-preview")
        };

        var description_row = new Adw.ActionRow ();
        description_row.title = _("Description preview");
        description_row.set_activatable_widget (description_switch);
        description_row.add_suffix (description_switch);

        tasks_group.add (description_row);

        var underline_completed_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Planner.settings.get_boolean ("underline-completed-tasks")
        };

        var underline_completed_row = new Adw.ActionRow ();
        underline_completed_row.title = _("Underline completed tasks");
        underline_completed_row.set_activatable_widget (underline_completed_switch);
        underline_completed_row.add_suffix (underline_completed_switch);

        // tasks_group.add (underline_completed_row);

        page.add (general_group);
        page.add (de_group);
        page.add (datetime_group);
        page.add (tasks_group);

        sort_projects_row.notify["selected"].connect (() => {
            Planner.settings.set_enum ("projects-sort-by", (int) sort_projects_row.selected);
        });

        sort_order_projects_row.notify["selected"].connect (() => {
            Planner.settings.set_enum ("projects-ordered", (int) sort_order_projects_row.selected);
        });

        run_background_switch.notify["active"].connect (() => {
            Planner.settings.set_boolean ("run-in-background", run_background_switch.active);
        });

        calendar_events_switch.notify["active"].connect (() => {
            Planner.settings.set_boolean ("calendar-enabled", calendar_events_switch.active);
        });

        clock_format_row.notify["selected"].connect (() => {
            Planner.settings.set_enum ("clock-format", (int) clock_format_row.selected);
        });
        
        start_week_row.notify["selected"].connect (() => {
            Planner.settings.set_enum ("start-week", (int) start_week_row.selected);
        });
        
        complete_tasks_row.notify["selected"].connect (() => {
            Planner.settings.set_enum ("complete-task", (int) complete_tasks_row.selected);
        });

        default_priority_row.notify["selected"].connect (() => {
            Planner.settings.set_enum ("default-priority", (int) default_priority_row.selected);
        });
        
        description_switch.notify["active"].connect (() => {
            Planner.settings.set_boolean ("description-preview", description_switch.active);
        });
        
        underline_completed_switch.notify["active"].connect (() => {
            Planner.settings.set_boolean ("underline-completed-tasks", underline_completed_switch.active);
        });

        return page;
    }

    private void build_appearance (Adw.PreferencesPage page) {
        var appearance_group = new Adw.PreferencesGroup ();
        appearance_group.title = _("Appearance");

        var system_appearance_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Planner.settings.get_boolean ("system-appearance")
        };

        var system_appearance_row = new Adw.ActionRow ();
        system_appearance_row.title = _("Use system settings");
        system_appearance_row.set_activatable_widget (system_appearance_switch);
        system_appearance_row.add_suffix (system_appearance_switch);

        appearance_group.add (system_appearance_row);

        var dark_mode_group = new Adw.PreferencesGroup () {
            visible = !Planner.settings.get_boolean ("system-appearance")
        };

        var dark_mode_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Planner.settings.get_boolean ("dark-mode")
        };

        var dark_mode_row = new Adw.ActionRow ();
        dark_mode_row.title = _("Dark mode");
        dark_mode_row.set_activatable_widget (dark_mode_switch);
        dark_mode_row.add_suffix (dark_mode_switch);

        dark_mode_group.add (dark_mode_row);

        var light_check = new Gtk.CheckButton ();

        var dark_check = new Gtk.CheckButton ();
        dark_check.set_group (light_check);

        var dark_item_row = new Adw.ActionRow ();
        dark_item_row.title = _("Dark");
        dark_item_row.set_activatable_widget (dark_check);
        dark_item_row.add_suffix (dark_check);

        var dark_blue_check = new Gtk.CheckButton ();
        dark_blue_check.set_group (light_check);

        var dark_blue_item_row = new Adw.ActionRow ();
        dark_blue_item_row.title = _("Dark Blue");
        dark_blue_item_row.set_activatable_widget (dark_blue_check);
        dark_blue_item_row.add_suffix (dark_blue_check);

        bool dark_mode = Planner.settings.get_boolean ("dark-mode");
        if (Planner.settings.get_boolean ("system-appearance")) {
            dark_mode = Granite.Settings.get_default ().prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        }

        var dark_modes_group = new Adw.PreferencesGroup () {
            visible = dark_mode
        };

        dark_modes_group.add (dark_item_row);
        dark_modes_group.add (dark_blue_item_row);

        int appearance = Planner.settings.get_enum ("appearance");
        if (appearance == 0) {
            light_check.active = true;
        } else if (appearance == 1) {
            dark_check.active = true;
        } else if (appearance == 2) {
            dark_blue_check.active = true;
        }

        system_appearance_switch.notify["active"].connect (() => {
            Planner.settings.set_boolean ("system-appearance", system_appearance_switch.active);
        });

        dark_mode_switch.notify["active"].connect (() => {
            Planner.settings.set_boolean ("dark-mode", dark_mode_switch.active);
        });
        
        dark_check.toggled.connect (() => {
            Planner.settings.set_enum ("appearance", 1);
        });
        
        dark_blue_check.toggled.connect (() => {
            Planner.settings.set_enum ("appearance", 2);
        });

        dark_item_row.activated.connect (() => {
            dark_check.active = true;
        });

        dark_blue_item_row.activated.connect (() => {
            dark_blue_check.active = true;
        });

        Planner.settings.changed.connect ((key) => {
            if (key == "system-appearance") {
                system_appearance_switch.active = Planner.settings.get_boolean ("system-appearance");
                dark_mode_group.visible = !Planner.settings.get_boolean ("system-appearance");

                dark_mode = Planner.settings.get_boolean ("dark-mode");
                if (Planner.settings.get_boolean ("system-appearance")) {
                    dark_mode = Granite.Settings.get_default ().prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
                }
                
                dark_modes_group.visible = dark_mode;
            } else if (key == "dark-mode") {
                dark_mode_switch.active = Planner.settings.get_boolean ("dark-mode");
                
                dark_mode = Planner.settings.get_boolean ("dark-mode");
                if (Planner.settings.get_boolean ("system-appearance")) {
                    dark_mode = Granite.Settings.get_default ().prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
                }

                dark_modes_group.visible = dark_mode;
            }
        });

        page.add (appearance_group);
        page.add (dark_mode_group);
        page.add (dark_modes_group);
    }

    private Adw.PreferencesPage get_accounts_page () {
        var page = new Adw.PreferencesPage ();
        page.title = _("Accounts");
        page.name = "accounts";
        page.icon_name = "org.gnome.Settings-users-symbolic";

        var default_group = new Adw.PreferencesGroup () {
            visible = Services.Todoist.get_default ().is_logged_in ()
        };

        var inbox_project_model = new Gtk.StringList (null);
        inbox_project_model.append (_("On This Computer"));
        inbox_project_model.append (_("Todoist"));

        var inbox_project_row = new Adw.ComboRow ();
        inbox_project_row.title = _("Default Inbox Project");
        inbox_project_row.model = inbox_project_model;
        inbox_project_row.selected = Planner.settings.get_enum ("default-inbox");

        default_group.add (inbox_project_row);

        // Todoist
        var todoist_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Services.Todoist.get_default ().is_logged_in ()
        };

        var todoist_setting_image = new Widgets.DynamicIcon ();
        todoist_setting_image.size = 19;
        todoist_setting_image.update_icon_name ("applications-system-symbolic");

        var todoist_setting_button = new Gtk.Button () {
            margin_end = 6,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };
        todoist_setting_button.child = todoist_setting_image;
        todoist_setting_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var todoist_setting_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            reveal_child = Services.Todoist.get_default ().is_logged_in ()
        };
        
        todoist_setting_revealer.child = todoist_setting_button;

        var todoist_row = new Adw.ActionRow ();
        todoist_row.icon_name = "planner-todoist";
        todoist_row.title = _("Todoist");
        todoist_row.subtitle = _("Synchronize with your Todoist Account");
        todoist_row.add_suffix (todoist_setting_revealer);
        todoist_row.add_suffix (todoist_switch);

        // Google Tasks
        var google_tasks_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = false,
            sensitive = false
        };

        var google_tasks_image = new Widgets.DynamicIcon ();
        google_tasks_image.size = 19;
        google_tasks_image.update_icon_name ("applications-system-symbolic");

        var google_tasks_button = new Gtk.Button () {
            margin_end = 6,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };
        google_tasks_button.child = google_tasks_image;
        google_tasks_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var google_tasks_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            reveal_child = false
        };
        
        google_tasks_revealer.child = google_tasks_button;

        var google_row = new Adw.ActionRow ();
        google_row.icon_name = "google";
        google_row.title = _("Google Tasks");
        google_row.subtitle = _("Synchronize with your Google Account");
        google_row.add_suffix (google_tasks_revealer);
        google_row.add_suffix (google_tasks_switch);
            
        var accounts_group = new Adw.PreferencesGroup ();
        accounts_group.title = _("Accounts");

        accounts_group.add (todoist_row);
        accounts_group.add (google_row);

        page.add (default_group);
        page.add (accounts_group);

        var todoist_switch_gesture = new Gtk.GestureClick ();
        todoist_switch_gesture.set_button (1);
        todoist_switch.add_controller (todoist_switch_gesture);

        todoist_switch_gesture.pressed.connect (() => {
            todoist_switch.active = !todoist_switch.active;

            if (todoist_switch.active) {
                todoist_switch.active = false;
                Services.Todoist.get_default ().init ();
            } else {
                confirm_log_out (todoist_switch);
            }
        });

        Services.Todoist.get_default ().first_sync_finished.connect (() => {
            todoist_setting_revealer.reveal_child = Services.Todoist.get_default ().is_logged_in ();
            todoist_switch.active = Services.Todoist.get_default ().is_logged_in ();
        });

        Services.Todoist.get_default ().log_out.connect (() => {
            todoist_setting_revealer.reveal_child = Services.Todoist.get_default ().is_logged_in ();
            todoist_switch.active = Services.Todoist.get_default ().is_logged_in ();
        });

        todoist_setting_button.clicked.connect (() => {
            present_subpage (get_todoist_view ());
            can_navigate_back = true;
        });

        inbox_project_row.notify["selected"].connect (() => {
            Planner.settings.set_enum ("default-inbox", (int) inbox_project_row.selected);
            Util.get_default ().change_default_inbox ();
        });

        return page;
    }

    private void confirm_log_out (Gtk.Switch todoist_switch) {
        var dialog = new Adw.MessageDialog ((Gtk.Window) Planner.instance.main_window, 
        _("Sign off"), _("Are you sure you want to remove the Todoist sync? This action will delete all your tasks and settings."));

        dialog.body_use_markup = true;
        dialog.add_response ("cancel", _("Cancel"));
        dialog.add_response ("delete", _("Delete"));
        dialog.set_response_appearance ("delete", Adw.ResponseAppearance.DESTRUCTIVE);
        dialog.show ();

        dialog.response.connect ((response) => {
            if (response == "delete") {
                Services.Todoist.get_default ().remove_items ();
            } else {
                todoist_switch.active = true;
            }
        });
    }

    private Gtk.Widget get_todoist_view () {
        var settings_header_box = new Widgets.SettingsHeader (_("Todoist"));

        var settings_header = new Gtk.HeaderBar () {
            title_widget = settings_header_box,
            show_title_buttons = false,
            hexpand = true
        };

        settings_header.add_css_class (Granite.STYLE_CLASS_FLAT);

        var todoist_avatar = new Adw.Avatar (84, Planner.settings.get_string ("todoist-user-name"), true);

        var file = File.new_for_path (Util.get_default ().get_todoist_avatar_path ());
        if (file.query_exists ()) {
            // todoist_avatar.set_loadable_icon (new FileIcon (file));    
        }

        var todoist_user = new Gtk.Label (Planner.settings.get_string ("todoist-user-name")) {
            margin_top = 12
        };
        todoist_user.add_css_class ("title-1");

        var todoist_email = new Gtk.Label (Planner.settings.get_string ("todoist-user-email"));
        todoist_email.get_style_context ().add_class (Granite.STYLE_CLASS_DIM_LABEL);

        var user_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin_top = 64
        };
        user_box.append (todoist_avatar);
        user_box.append (todoist_user);
        user_box.append (todoist_email);

        var default_group = new Adw.PreferencesGroup ();

        var content_clamp = new Adw.Clamp () {
            maximum_size = 400,
            margin_top = 24,
            margin_start = 24,
            margin_end = 24
        };

        content_clamp.child = default_group;

        var sync_server_switch = new Gtk.Switch () {
            valign = Gtk.Align.CENTER,
            active = Planner.settings.get_boolean ("todoist-sync-server")
        };

        var sync_server_row = new Adw.ActionRow ();
        sync_server_row.title = _("Sync Server");
        sync_server_row.subtitle = _("Activate this setting so that Planner automatically synchronizes with your Todoist account every 15 minutes.");
        sync_server_row.set_activatable_widget (sync_server_switch);
        sync_server_row.add_suffix (sync_server_switch);

        var last_sync_date = new GLib.DateTime.from_iso8601 (
            Planner.settings.get_string ("todoist-last-sync"), new GLib.TimeZone.local ()
        );

        var last_sync_label = new Gtk.Label (Util.get_default ().get_relative_date_from_date (
            last_sync_date
        ));
        
        var last_sync_row = new Adw.ActionRow ();
        last_sync_row.activatable = false;
        last_sync_row.title = _("Last Sync");
        last_sync_row.add_suffix (last_sync_label);

        default_group.add (sync_server_row);
        default_group.add (last_sync_row);

        var main_content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            vexpand = true,
            hexpand = true
        };

        main_content.append (settings_header);
        main_content.append (user_box);
        main_content.append (content_clamp);

        settings_header_box.back_activated.connect (() => {
            close_subpage ();
        });

        sync_server_row.notify["active"].connect (() => {
            Planner.settings.set_boolean ("todoist-sync-server", sync_server_switch.active);
        });

        return main_content;
    }
}
