public class Views.Pinboard : Gtk.Grid {
    public Gee.HashMap <string, Layouts.ItemRow> items;
    private Gtk.ListBox listbox;
    private Gtk.Stack listbox_stack;

    private bool has_items {
        get {
            return Util.get_default ().get_children (listbox).length () > 0;
        }
    }

    construct {
        items = new Gee.HashMap <string, Layouts.ItemRow> ();

        var headerbar = new Widgets.FilterHeader (Objects.Pinboard.get_default ());

        var magic_button = new Widgets.MagicButton ();

        listbox = new Gtk.ListBox () {
            valign = Gtk.Align.START,
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE,
            hexpand = true
        };

        listbox.add_css_class ("listbox-background");

        var listbox_grid = new Gtk.Grid () {
            margin_top = 12
        };

        listbox_grid.attach (listbox, 0, 0);

        var listbox_placeholder = new Widgets.Placeholder (
            _("Press 'a' or tap the plus button to create a new to-do"), "planner-check-circle"
        );

        listbox_stack = new Gtk.Stack () {
            hexpand = true,
            vexpand = true,
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };

        listbox_stack.add_named (listbox_grid, "listbox");
        listbox_stack.add_named (listbox_placeholder, "placeholder");

        var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            hexpand = true,
            vexpand = true
        };

        content.append (listbox_stack);

        var content_clamp = new Adw.Clamp () {
            maximum_size = 720
        };

        content_clamp.child = content;

        var scrolled_window = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            hexpand = true,
            vexpand = true
        };

        scrolled_window.child = content_clamp;

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            hexpand = true,
            vexpand = true
        };

        content_box.append (headerbar);
        content_box.append (scrolled_window);

        attach (content_box, 0, 0);
        add_items ();

        Timeout.add (listbox_stack.transition_duration, () => {
            validate_placeholder ();
            return GLib.Source.REMOVE;
        });

        magic_button.clicked.connect (() => {
            prepare_new_item ();
        });

        Services.Database.get_default ().item_added.connect (valid_add_item);
        Services.Database.get_default ().item_deleted.connect (valid_delete_item);
        Services.Database.get_default ().item_updated.connect (valid_update_item);

        Planner.event_bus.item_moved.connect ((item) => {
            if (items.has_key (item.id_string)) {
                items[item.id_string].update_request ();
            }
        });

        //  listbox.add.connect (() => {
        //      validate_placeholder ();
        //  });

        //  listbox.remove.connect (() => {
        //      validate_placeholder ();
        //  });

        scrolled_window.vadjustment.value_changed.connect (() => {
            if (scrolled_window.vadjustment.value > 20) {
                Planner.event_bus.view_header (true);
            } else {
                Planner.event_bus.view_header (false);
            }
        });
    }

    private void validate_placeholder () {
        // listbox_stack.visible_child_name = has_items ? "listbox" : "placeholder";
    }

    public void prepare_new_item (string content = "") {
        Planner.event_bus.item_selected (null);

        var row = new Layouts.ItemRow.for_project (
            Services.Database.get_default ().get_project (Planner.settings.get_string ("inbox-project-id"))
        );

        row.update_content (content);
        row.update_priority (Util.get_default ().get_default_priority ());
        row.update_pinned (true);
        
        row.item_added.connect (() => {
            item_added (row);
        });

        listbox.append (row);
    }

    private void item_added (Layouts.ItemRow row) {
        bool insert = !row.item.pinned;

        if (!insert) {
            valid_add_itemrow (row);
            row.update_inserted_item ();
        }

        if (row.item.section_id != "") {
            Services.Database.get_default ().get_section (row.item.section_id)
                .add_item_if_not_exists (row.item);
        } else {
            Services.Database.get_default ().get_project (row.item.project_id)
                .add_item_if_not_exists (row.item);
        }

        if (insert) {
            row.hide_destroy ();
        }
    }

    private void valid_add_itemrow (Layouts.ItemRow row) {
        if (!items.has_key (row.item.id_string) && row.item.pinned) {
            items [row.item.id_string] = row;
            listbox.append (items [row.item.id_string]);
        }
    }

    private void valid_add_item (Objects.Item item, bool insert = true) {        
        if (!items.has_key (item.id_string) && item.pinned && !item.checked) {
            add_item (item);   
        }
    }

    private void valid_delete_item (Objects.Item item) {
        if (items.has_key (item.id_string)) {
            items[item.id_string].hide_destroy ();
            items.unset (item.id_string);
        }
    }

    private void valid_update_item (Objects.Item item) {
        if (items.has_key (item.id_string) && (!item.pinned || item.checked)) {
            items[item.id_string].hide_destroy ();
            items.unset (item.id_string);
        }

        valid_add_item (item);
    }

    private void add_items () {
        foreach (Objects.Item item in Services.Database.get_default ().get_items_pinned (false)) {
            add_item (item);
        }
    }

    private void add_item (Objects.Item item) {
        items [item.id_string] = new Layouts.ItemRow (item);
        listbox.append (items [item.id_string]);
    }
}