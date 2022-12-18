public class Layouts.ItemRow : Gtk.ListBoxRow {
    public Objects.Item item { get; construct; }

    public int64 project_id { get; set; default = Constants.INACTIVE; }
    public int64 section_id { get; set; default = Constants.INACTIVE; }
    public int64 parent_id { get; set; default = Constants.INACTIVE; }

    private Gtk.CheckButton checked_button;
    private Widgets.SourceView content_textview;
    private Gtk.Revealer hide_loading_revealer;
    
    private Gtk.Label content_label;

    private Gtk.Revealer content_label_revealer;
    private Gtk.Revealer content_entry_revealer;

    private Gtk.Box content_top_box;
    private Gtk.Revealer detail_revealer;
    private Gtk.Revealer main_revealer;
    private Gtk.Box handle_grid;
    private Gtk.Popover menu_popover = null;
    //  private Gtk.Revealer top_motion_revealer;
    //  private Gtk.Revealer bottom_motion_revealer;
    //  private Gtk.EventBox itemrow_eventbox;
    private Gtk.Button cancel_button;
    private Gtk.Revealer actionbar_revealer;
    //  public Widgets.ProjectButton project_button;
    private Widgets.LoadingButton hide_loading_button;
    private Widgets.LoadingButton submit_button;
    private Widgets.HyperTextView description_textview;
    private Widgets.ItemLabels item_labels;
    private Widgets.ScheduleButton schedule_button;
    private Widgets.ItemSummary item_summary;
    private Widgets.PriorityButton priority_button;
    private Widgets.LabelButton label_button;
    private Widgets.PinButton pin_button;
    //  private Widgets.ReminderButton reminder_button;
    //  private Gtk.Button add_button;
    private Gtk.Revealer submit_cancel_revealer;
    private Gtk.Button delete_button;
    private Gtk.Button menu_button;
    private Gtk.Revealer delete_button_revealer;
    private Gtk.Revealer menu_button_revealer;
    //  private Widgets.SubItems subitems;
    private Gtk.Button hide_subtask_button;
    private Gtk.Revealer hide_subtask_revealer;
    private Gtk.Box main_grid;
    //  private Gtk.EventBox itemrow_eventbox_eventbox;
    
    bool _edit = false;
    public bool edit {
        set {
            _edit = value;
            
            if (value) {
                handle_grid.add_css_class ("card");
                handle_grid.add_css_class ("card-selected");
                handle_grid.add_css_class (is_creating ? "mt-12" : "mt-24");
                add_css_class ("mb-12");
                add_css_class ("font-weight-500");
                hide_subtask_button.margin_top = 27;

                detail_revealer.reveal_child = true;
                content_label_revealer.reveal_child = false;
                content_entry_revealer.reveal_child = true;
                actionbar_revealer.reveal_child = true;
                item_summary.reveal_child = false;
                hide_loading_revealer.reveal_child = !is_creating;

                content_textview.grab_focus ();
                //  if (content_entry.cursor_position < content_entry.text_length) {
                //      content_entry.move_cursor (Gtk.MovementStep.BUFFER_ENDS, (int32) content_entry.text_length, false);
                //  }

                if (complete_timeout != 0) {
                    main_grid.get_style_context ().remove_class ("complete-animation");
                    content_label.get_style_context ().remove_class ("dim-label");
                }
            } else {
                handle_grid.remove_css_class ("card");
                handle_grid.remove_css_class ("card-selected");
                handle_grid.remove_css_class ("mt-12");
                handle_grid.remove_css_class ("mt-24");
                remove_css_class ("mb-12");
                content_textview.remove_css_class ("font-weight-500");
                hide_subtask_button.margin_top = 3;

                detail_revealer.reveal_child = false;
                content_label_revealer.reveal_child = true;
                content_entry_revealer.reveal_child = false;
                actionbar_revealer.reveal_child = false;
                item_summary.check_revealer ();
                hide_loading_revealer.reveal_child = false;

                update_request ();
            }
        }
        get {
            return _edit;
        }
    }

    //  public bool item_selected {
    //      set {
    //          if (value) {
    //              itemrow_eventbox.get_style_context ().add_class ("complete-animation");
    //          } else {
    //              itemrow_eventbox.get_style_context ().remove_class ("complete-animation");
    //          }
    //      }
    //  }

    public bool reveal {
        set {
            main_revealer.reveal_child = true;
        }

        get {
            return main_revealer.reveal_child;
        }
    }

    public bool is_creating {
        get {
            return item.id == Constants.INACTIVE;
        }
    }

    public bool is_loading {
        set {
            if (value) {
                hide_loading_revealer.reveal_child = value;
                hide_loading_button.is_loading = value;
            } else {
                hide_loading_button.is_loading = value;
                hide_loading_revealer.reveal_child = edit;
            }
        }
    }

    public uint destroy_timeout { get; set; default = 0; }
    public uint complete_timeout { get; set; default = 0; }
    public int64 update_id { get; set; default = Util.get_default ().generate_id (); }
    public bool is_menu_open { get; set; default = false; }

    public signal void item_added ();

    public ItemRow (Objects.Item item) {
        Object (
            item: item,
            focusable: false,
            can_focus: true
        );
    }

    public ItemRow.for_item (Objects.Item _item) {
        var item = new Objects.Item ();
        item.project_id = _item.project_id;
        item.section_id = _item.section_id;

        Object (
            item: item,
            focusable: false,
            can_focus: true
        );
    }

    public ItemRow.for_project (Objects.Project project) {
        var item = new Objects.Item ();
        item.project_id = project.id;

        Object (
            item: item,
            focusable: false,
            can_focus: true
        );
    }

    public ItemRow.for_parent (Objects.Item _item) {
        var item = new Objects.Item ();
        item.project_id = _item.project_id;
        item.section_id = _item.section_id;
        item.parent_id = _item.id;
        
        Object (
            item: item,
            focusable: false,
            can_focus: true
        );
    }

    public ItemRow.for_section (Objects.Section section) {
        var item = new Objects.Item ();
        item.section_id = section.id;
        item.project_id = section.project.id;

        Object (
            item: item,
            focusable: false,
            can_focus: true
        );
    }

    construct {
        add_css_class ("row");

        project_id = item.project_id;
        section_id = item.section_id;
        parent_id = item.parent_id;

        if (is_creating) {
            Planner.event_bus.update_section_sort_func (project_id, section_id, false);
        }

        checked_button = new Gtk.CheckButton () {
            can_focus = false,
            valign = Gtk.Align.CENTER
        };

        checked_button.add_css_class ("priority-color");

        content_label = new Gtk.Label (item.content) {
            hexpand = true,
            xalign = 0,
            wrap = true,
            ellipsize = Pango.EllipsizeMode.NONE
        };

        content_label_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_UP,
            transition_duration = 125,
            reveal_child = true
        };

        content_label_revealer.child = content_label;

        content_textview = new Widgets.SourceView ();
        content_textview.wrap_mode = Gtk.WrapMode.WORD;
        content_textview.buffer.text = item.content;

        content_textview.remove_css_class ("view");

        content_entry_revealer = new Gtk.Revealer () {
            valign = Gtk.Align.CENTER,
            transition_type = Gtk.RevealerTransitionType.SWING_DOWN,
            transition_duration = 125,
            reveal_child = false
        };

        content_entry_revealer.child = content_textview;

        hide_loading_button = new Widgets.LoadingButton.with_icon ("chevron-down", 19) {
            valign = Gtk.Align.START,
            can_focus = false
        };
        hide_loading_button.add_css_class (Granite.STYLE_CLASS_FLAT);
        hide_loading_button.add_css_class ("p3");
        hide_loading_button.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        hide_loading_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
            valign = Gtk.Align.START
        };
        hide_loading_revealer.child = hide_loading_button;

        var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            valign = Gtk.Align.CENTER,
            margin_start = 6
        };
        content_box.hexpand = true;
        content_box.append (content_label_revealer);
        content_box.append (content_entry_revealer);

        content_top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        content_top_box.append (checked_button);
        content_top_box.append (content_box);
        content_top_box.append (hide_loading_revealer);

        item_summary = new Widgets.ItemSummary (item, this) {
            margin_start = 32
        };

        description_textview = new Widgets.HyperTextView (_("Description")) {
            height_request = 64,
            left_margin = 32,
            right_margin = 6,
            top_margin = 3,
            bottom_margin = 12,
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            hexpand = true,
            editable = !item.completed
        };

        description_textview.remove_css_class ("view");

        //  var description_scrolled = new Gtk.ScrolledWindow () {
        //      vscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
        //      hexpand = true,
        //      vexpand = true,
        //      height_request = 120
        //  };

        //  description_scrolled.child = description_textview;

        //  item_labels = new Widgets.ItemLabels (item) {
        //      margin_start = 21,
        //      margin_bottom = 6,
        //      sensitive = !item.completed
        //  };

        //  project_button = new Widgets.ProjectButton (item) {
        //      sensitive = !item.completed
        //  };

        schedule_button = new Widgets.ScheduleButton ();

        priority_button = new Widgets.PriorityButton ();
        
        label_button = new Widgets.LabelButton (item);

        pin_button = new Widgets.PinButton (item);
        
        //  reminder_button = new Widgets.ReminderButton (item) {
        //      no_show_all = is_creating
        //  };
        //  reminder_button.get_style_context ().add_class ("no-padding");

        //  var add_image = new Widgets.DynamicIcon ();
        //  add_image.size = 19;
        //  add_image.update_icon_name ("planner-plus-circle");
        
        //  add_button = new Gtk.Button () {
        //      valign = Gtk.Align.CENTER,
        //      can_focus = false,
        //      tooltip_text = _("Add subtask"),
        //      margin_top = 1,
        //      no_show_all = is_creating
        //  };

        //  add_button.add (add_image);

        //  unowned Gtk.StyleContext add_button_context = add_button.get_style_context ();
        //  add_button_context.add_class (Gtk.STYLE_CLASS_FLAT);
        //  add_button_context.add_class ("no-padding");

        var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            margin_start = 27,
            margin_top = 6,
            hexpand = true,
            sensitive = !item.completed
        };

        var action_box_right = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true,
            halign = Gtk.Align.END
        };

        action_box_right.append (label_button);
        action_box_right.append (priority_button);
        action_box_right.append (pin_button);

        action_box.append (schedule_button);
        action_box.append (action_box_right);
        //  action_grid.pack_end (reminder_button, false, false, 0);
        //  action_grid.pack_end (add_button, false, false, 0);

        var details_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        details_grid.append (description_textview);
        // details_grid.append (item_labels);
        details_grid.append (action_box);

        detail_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        };

        detail_revealer.child = details_grid;

        handle_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            valign = Gtk.Align.START
        };

        handle_grid.add_css_class ("transition");
        handle_grid.append (content_top_box);
        handle_grid.append (item_summary);
        handle_grid.append (detail_revealer);

        var chevron_right_image = new Widgets.DynamicIcon ();
        chevron_right_image.size = 19;
        chevron_right_image.update_icon_name ("chevron-right");

        hide_subtask_button = new Gtk.Button () {
            valign = Gtk.Align.START,
            margin_top = 6,
            can_focus = false
        };
        hide_subtask_button.add_css_class (Granite.STYLE_CLASS_FLAT);
        hide_subtask_button.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        hide_subtask_button.add_css_class ("no-padding");
        hide_subtask_button.add_css_class ("hidden-button");
        hide_subtask_button.child = chevron_right_image;

        hide_subtask_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE,
            reveal_child = false
        };

        hide_subtask_revealer.child = hide_subtask_button;

        var itemrow_eventbox_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        itemrow_eventbox_box.append (hide_subtask_revealer);
        itemrow_eventbox_box.append (handle_grid);

        submit_button = new Widgets.LoadingButton (LoadingButtonType.LABEL, _("Add Task")) {
            can_focus = false
        };
        submit_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);
        submit_button.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);
        submit_button.add_css_class ("border-radius-6");
        submit_button.add_css_class ("action-button");

        cancel_button = new Gtk.Button.with_label (_("Cancel")) {
            can_focus = false
        };
        cancel_button.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);
        cancel_button.add_css_class ("border-radius-6");
        cancel_button.add_css_class ("action-button");
        
        var submit_cancel_grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin_top = 3
        };
        submit_cancel_grid.append (cancel_button);
        submit_cancel_grid.append (submit_button);

        submit_cancel_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
            reveal_child = is_creating
        };

        submit_cancel_revealer.child = submit_cancel_grid;

        var menu_image = new Widgets.DynamicIcon ();
        menu_image.size = 19;
        menu_image.update_icon_name ("dots-horizontal");
        
        menu_button = new Gtk.Button () {
            can_focus = false
        };

        menu_button.child = menu_image;
        menu_button.add_css_class (Granite.STYLE_CLASS_FLAT);
        
        // menu_button.clicked.connect (build_context_menu);

        menu_button_revealer = new Gtk.Revealer () {
            reveal_child = !is_creating
        };

        menu_button_revealer.child = menu_button;

        var trash_image = new Widgets.DynamicIcon ();
        trash_image.size = 19;
        trash_image.update_icon_name ("planner-trash");

        delete_button = new Gtk.Button () {
            can_focus = false
        };

        delete_button.child = trash_image;
        delete_button.get_style_context ().add_class (Granite.STYLE_CLASS_FLAT);

        delete_button_revealer = new Gtk.Revealer () {
            reveal_child = !is_creating
        };

        delete_button_revealer.child = delete_button;

        var project_delete_menu_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true,
            halign = Gtk.Align.END
        };

        // project_delete_menu_box.append (project_button);
        project_delete_menu_box.append (delete_button_revealer);
        project_delete_menu_box.append (menu_button_revealer);

        var actionbar_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 22,
            margin_end = 6
        };

        actionbar_box.append (submit_cancel_revealer);
        actionbar_box.append (project_delete_menu_box);

        actionbar_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        };

        actionbar_revealer.child = actionbar_box;

        //  subitems = new Widgets.SubItems (item);

        main_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        main_grid.add_css_class ("transition");
        // main_grid.append (top_motion_revealer);
        main_grid.append (itemrow_eventbox_box);
        main_grid.append (actionbar_revealer);
        // main_grid.append (subitems);
        // main_grid.append (bottom_motion_revealer);

        main_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN
        };
        
        main_revealer.child = main_grid;

        child = main_revealer;
        update_request ();

        Timeout.add (main_revealer.transition_duration, () => {
            main_revealer.reveal_child = true;
            
            if (is_creating) {
                edit = true;
            }

            //  if (!item.checked) {
            //      Gtk.drag_source_set (this, Gdk.ModifierType.BUTTON1_MASK, Util.get_default ().ITEMROW_TARGET_ENTRIES, Gdk.DragAction.MOVE);
            //      drag_begin.connect (on_drag_begin);
            //      drag_data_get.connect (on_drag_data_get);
            //      drag_end.connect (clear_indicator);
                
            //      build_drag_and_drop (false);     
            //  }

            return GLib.Source.REMOVE;
        });

        connect_signals ();
    }

    private void connect_signals () {
    //      itemrow_eventbox_eventbox.enter_notify_event.connect ((event) => {
    //          hide_subtask_revealer.reveal_child = !is_creating && item.items.size > 0;
    //          return false;
    //      });

    //      itemrow_eventbox_eventbox.leave_notify_event.connect ((event) => {
    //          if (event.detail == Gdk.NotifyType.INFERIOR) {
    //              return false;
    //          }

    //          hide_subtask_revealer.reveal_child = false;
    //          return false;
    //      });

        var handle_gesture_click = new Gtk.GestureClick ();
        handle_grid.add_controller (handle_gesture_click);

        handle_gesture_click.pressed.connect ((n_press, x, y) => {
            handle_gesture_click.set_state (Gtk.EventSequenceState.CLAIMED);

            if (Planner.event_bus.ctrl_pressed) {
                Planner.event_bus.select_item (this);
            } else if (Planner.event_bus.alt_pressed) {
                Util.get_default ().open_item_dialog (item);                    
            } else {
                Planner.event_bus.unselect_all ();

                Timeout.add (Constants.DRAG_TIMEOUT, () => {
                    if (main_revealer.reveal_child) {
                        Planner.event_bus.item_selected (item.id);
                    }

                    return GLib.Source.REMOVE;
                });
            }
        });

        Planner.event_bus.item_selected.connect ((id) => {
            if (item.id == id) {
                if (!edit) {
                    edit = true;
                }
            } else {
                if (edit) {
                    edit = false;
                }
            }
        });

        var content_controller_key = new Gtk.EventControllerKey ();
        content_textview.add_controller (content_controller_key);

        content_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (keyval == 65293) {
                if (is_creating) {
                    add_item ();
                } else {
                    edit = false;
                }
                
                return Gdk.EVENT_STOP;
            }

            return false;
        });

        content_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (keyval == 65307) {
                if (is_creating) {
                    hide_destroy ();
                } else {
                    Planner.event_bus.item_selected (null);
                }
            } else {
                if (!is_creating) {
                    update ();
                } else {
                    submit_button.sensitive = Util.get_default ().is_text_valid (content_textview);
                }
            }

            return false;
        });


    //      content_textview.focus_out_event.connect (() => {
    //          if (is_creating && !is_menu_open) {
    //              destroy_timeout = Timeout.add (Constants.DESTROY_TIMEOUT, () => {
    //                  hide_destroy ();
    //                  return GLib.Source.REMOVE;
    //              });
    //          }

    //          return false;
    //      });

    //      content_textview.focus_in_event.connect (() => {
    //          if (is_creating && destroy_timeout != 0) {
    //              Source.remove (destroy_timeout);
    //          }
        
    //          return false;
    //      });

    //      description_textview.focus_in_event.connect (() => {
    //          if (is_creating && destroy_timeout != 0) {
    //              Source.remove (destroy_timeout);
    //          }
        
    //          return false;
    //      });

        submit_button.clicked.connect (() => {
            add_item ();
        });

        cancel_button.clicked.connect (() => {
            if (is_creating) {
                Planner.event_bus.item_selected (null);
                hide_destroy ();
            }
        });

    //      content_textview.populate_popup.connect ((menu) => {
    //          is_menu_open = true;
    //          menu.hide.connect (() => {
    //              is_menu_open = false;
    //          });
    //      });

        var description_controller_key = new Gtk.EventControllerKey ();
        content_textview.add_controller (description_controller_key);

        description_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (keyval == 65307) {
                if (is_creating) {
                    hide_destroy ();
                } else {
                    Planner.event_bus.item_selected (null);
                }
            } else {
                if (!is_creating) {
                    update ();
                }
            }

            return false;
        });

        var checked_button_gesture = new Gtk.GestureClick ();
        checked_button_gesture.set_button (1);
        checked_button.add_controller (checked_button_gesture);

        checked_button_gesture.pressed.connect (() => {
            checked_button_gesture.set_state (Gtk.EventSequenceState.CLAIMED);

            if (!is_creating) {
                checked_button.active = !checked_button.active;
                checked_toggled (checked_button.active);
            }
        });

        var hide_loading_gesture = new Gtk.GestureClick ();
        hide_loading_gesture.set_button (1);
        hide_loading_button.add_controller (hide_loading_gesture);

        hide_loading_gesture.pressed.connect (() => {
            hide_loading_gesture.set_state (Gtk.EventSequenceState.CLAIMED);
            edit = false;
        });

        schedule_button.date_changed.connect ((datetime) => {
            update_due (datetime);
        });

    //      schedule_button.dialog_open.connect ((dialog_open) => {
    //          is_menu_open = dialog_open;
    //      });
        
    //      project_button.dialog_open.connect ((dialog_open) => {
    //          is_menu_open = dialog_open;
    //      });

    //      label_button.dialog_open.connect ((dialog_open) => {
    //          is_menu_open = dialog_open;
    //      });

    //      priority_button.dialog_open.connect ((dialog_open) => {
    //          is_menu_open = dialog_open;
    //      });

    //      reminder_button.dialog_open.connect ((dialog_open) => {
    //          is_menu_open = dialog_open;
    //      });

    //      project_button.changed.connect ((project_id, section_id) => {
    //          move (project_id, section_id);
    //      });

        priority_button.changed.connect ((priority) => {
            if (item.priority != priority) {
                item.priority = priority;

                if (is_creating) {
                    priority_button.update_from_item (item);
                } else {
                    if (item.project.todoist) {
                        item.update_async (Constants.INACTIVE, this);
                    } else {
                        item.update_local ();
                    }
                }
            }
        });

        pin_button.changed.connect (() => {
            update_pinned (!item.pinned);
        });

        // item_labels.labels_changed.connect (update_labels);
        label_button.labels_changed.connect (update_labels);

        delete_button.clicked.connect (() => {
            delete_request ();
        });

    //      Planner.event_bus.magic_button_activated.connect ((value) => {
    //          if (!item.checked) {
    //              build_drag_and_drop (value);
    //          }
    //      });

    //      add_button.clicked.connect (() => {
    //          subitems.prepare_new_item ();
    //      });

    //      hide_subtask_button.clicked.connect (() => {
    //          subitems.reveal_child = !subitems.reveal_child;

    //          if (subitems.reveal_child) {
    //              subitems.add_items ();
    //              hide_subtask_button.get_style_context ().add_class ("opened");
    //          } else {
    //              hide_subtask_button.get_style_context ().remove_class ("opened");
    //          }
    //      });

        Planner.event_bus.checked_toggled.connect ((i) => {
            if (item.id == i.parent_id) {
                item_summary.update_request ();
            }
        });

        Services.Database.get_default ().item_deleted.connect ((i) => {
            if (item.id == i.parent_id) {
                item_summary.update_request ();
            }
        });

        Planner.settings.changed.connect ((key) => {
            if (key == "underline-completed-tasks") {
                update_request ();
            }
        });

        var menu_gesture = new Gtk.GestureClick ();
        menu_gesture.set_button (3);
        handle_grid.add_controller (menu_gesture);

        menu_gesture.pressed.connect ((n_press, x, y) => {
            build_context_menu (x, y);
        });
    }

    //  private void move_item (int64 project_id, int64 section_id) {
    //      int64 old_project_id = item.project_id;
    //      int64 old_section_id = item.section_id;

    //      item.project_id = project_id;
    //      item.section_id = section_id;

    //      Planner.database.update_item (item);
    //      Planner.event_bus.item_moved (item, old_project_id, old_section_id);
    //      project_button.update_request ();
    //  }

    private void update () {
        if (item.content != content_textview.buffer.text ||
            item.description != description_textview.buffer.text) {
            item.content = content_textview.buffer.text;
            item.description = description_textview.get_text ();

            item.update_async_timeout (update_id, this);      
        }
    }

    private void add_item () {
        if (is_creating && destroy_timeout != 0) {
            Source.remove (destroy_timeout);
        }
        
        if (Util.get_default ().is_text_valid (content_textview)) {
            submit_button.is_loading = true;

            item.content = content_textview.buffer.text;
            item.description = description_textview.get_text ();

            if (item.project.todoist) {
                Services.Todoist.get_default ().add.begin (item, (obj, res) => {
                    int64? id = Services.Todoist.get_default ().add.end (res);
                    if (id != null) {
                        item.id = id;
                        item_added ();
                    }
                });
            } else {
                item.id = Util.get_default ().generate_id ();
                item_added ();
            }
        } else {
            hide_destroy ();
        }
    }

    public void update_inserted_item () {
        update_request ();

        submit_cancel_revealer.reveal_child = false;
        submit_button.is_loading = false;
        
        //  add_button.no_show_all = false;
        //  add_button.show_all ();

        delete_button_revealer.reveal_child = true;
        menu_button_revealer.reveal_child = true;

        //  reminder_button.no_show_all = false;
        //  reminder_button.show_all ();

        edit = false;
    }

    public void update_request () {
        if (complete_timeout <= 0) {
            Util.get_default ().set_widget_priority (item.priority, checked_button);
            checked_button.active = item.completed;

            if (item.completed && Planner.settings.get_boolean ("underline-completed-tasks")) {
                content_label.add_css_class ("line-through");
            } else if (item.completed && !Planner.settings.get_boolean ("underline-completed-tasks")) {
                content_label.remove_css_class ("line-through");
            }
        }

        content_label.label = item.content;
        content_label.tooltip_text = item.content;
        content_textview.buffer.text = item.content;
        description_textview.set_text (item.description);
                
        item_summary.update_request ();
        schedule_button.update_from_item (item);
        priority_button.update_from_item (item);
        // project_button.update_request ();
        pin_button.update_request ();
        // item_labels.update_labels ();

        if (!edit) {
            // item_summary.check_revealer ();
        }
    }

    public void hide_destroy () {
        main_revealer.reveal_child = false;
        Timeout.add (main_revealer.transition_duration, () => {
            ((Gtk.ListBox) parent).remove (this);
            return GLib.Source.REMOVE;
        });
    }
    
    public void update_pinned (bool pinned) {
        item.pinned = pinned;

        if (is_creating) {
            pin_button.update_request ();
        } else {
            item.update_local ();
        }
    }

    private void build_context_menu (double x, double y) {
        if (menu_popover != null) {
            menu_popover.pointing_to = { (int) x, (int) y, 1, 1 };
            menu_popover.popup();
            return;
        }

        var today_item = new Widgets.ContextMenu.MenuItem (_("Today"), "planner-today");
        today_item.secondary_text = new GLib.DateTime.now_local ().format ("%a");

        var tomorrow_item = new Widgets.ContextMenu.MenuItem (_("Tomorrow"), "planner-scheduled");
        tomorrow_item.secondary_text = new GLib.DateTime.now_local ().add_days (1).format ("%a");
        
        var no_date_item = new Widgets.ContextMenu.MenuItem (_("No Date"), "planner-close-circle");

        var labels_item = new Widgets.ContextMenu.MenuItem (_("Labels"), "planner-tag");
        var reminders_item = new Widgets.ContextMenu.MenuItem (_("Reminders"), "planner-bell");
        var move_item = new Widgets.ContextMenu.MenuItem (_("Move"), "chevron-right");

        var complete_item = new Widgets.ContextMenu.MenuItem (_("Complete"), "planner-check-circle");
        var edit_item = new Widgets.ContextMenu.MenuItem (_("Edit"), "planner-edit");

        var delete_item = new Widgets.ContextMenu.MenuItem (_("Delete task"), "planner-trash");
        delete_item.get_style_context ().add_class ("menu-item-danger");

        var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        menu_box.margin_top = menu_box.margin_bottom = 3;
        menu_box.append (today_item);
        menu_box.append (tomorrow_item);
        if (item.has_due) {
            menu_box.append (no_date_item);
        }
        menu_box.append (new Dialogs.ContextMenu.MenuSeparator ());
        menu_box.append (labels_item);
        menu_box.append (reminders_item);
        menu_box.append (move_item);
        menu_box.append (new Dialogs.ContextMenu.MenuSeparator ());
        menu_box.append (complete_item);
        menu_box.append (edit_item);
        menu_box.append (new Dialogs.ContextMenu.MenuSeparator ());
        menu_box.append (delete_item);

        menu_popover = new Gtk.Popover () {
            has_arrow = false,
            child = menu_box,
            position = Gtk.PositionType.RIGHT,
            width_request = 225
        };

        menu_popover.set_parent (this);
        menu_popover.pointing_to = { (int) x, (int) y, 1, 1 };

        menu_popover.popup();

        //  labels_item.activate_item.connect (() => {
        //      menu.hide_destroy ();

        //      var dialog = new Dialogs.LabelPicker.LabelPicker ();
        //      dialog.item = item;
            
        //      dialog.labels_changed.connect ((labels) => {
        //          update_labels (labels);
        //      });

        //      dialog.popup ();
        //  });

        //  reminders_item.activate_item.connect (() => {
        //      menu.hide_destroy ();
        //      var dialog = new Dialogs.ReminderPicker.ReminderPicker (item);
        //      dialog.popup ();
        //  });

        //  move_item.activate_item.connect (() => {
        //      menu.hide_destroy ();
            
        //      var picker = new Dialogs.ProjectPicker.ProjectPicker ();
            
        //      if (item.has_section) {
        //          picker.section = item.section;
        //      } else {
        //          picker.project = item.project;
        //      }
            
        //      picker.popup ();

        //      picker.changed.connect ((project_id, section_id) => {
        //          move (project_id, section_id);
        //      });
        //  });

        today_item.activate_item.connect (() => {
            menu_popover.popdown ();
            update_due (Util.get_default ().get_format_date (new DateTime.now_local ()));
        });

        tomorrow_item.activate_item.connect (() => {
            menu_popover.popdown ();
            update_due (Util.get_default ().get_format_date (new DateTime.now_local ().add_days (1)));
        });

        no_date_item.activate_item.connect (() => {
            menu_popover.popdown ();
            update_due (null);
        });

        complete_item.activate_item.connect (() => {
            menu_popover.popdown ();
            checked_button.active = !checked_button.active;
            checked_toggled (checked_button.active);
        });

        edit_item.activate_item.connect (() => {
            menu_popover.popdown ();
            edit = true;
        });

        delete_item.activate_item.connect (() => {
            menu_popover.popdown ();
            delete_request ();
        });
    }

    //  private void build_context_menu () {
    //      Planner.event_bus.unselect_all ();
    //      var menu = new Dialogs.ContextMenu.Menu ();

    //      var repeat_item = new Widgets.ContextMenu.MenuItem (_("Repeat…"), "planner-refresh");

    //      menu.add_item (repeat_item);
    //      menu.popup ();

    //      repeat_item.activate_item.connect (() => {
    //          menu.hide_destroy ();

    //          var dialog = new Dialogs.Repeat ();
    //          dialog.popup ();
    //      });
    //  }

    public void checked_toggled (bool active, uint? time = null) {
        Planner.event_bus.unselect_all ();
        bool old_checked = item.checked;

        if (active) {
            if (!edit) {
                content_label.add_css_class ("dim-label");
                handle_grid.add_css_class ("complete-animation");
                if (Planner.settings.get_boolean ("underline-completed-tasks")) {
                    content_label.add_css_class ("line-through");
                }
            }

            uint timeout = Planner.settings.get_enum ("complete-task") == 0 ? 0 : 2500;
            if (time != null) {
                timeout = time;
            }

            complete_timeout = Timeout.add (timeout, () => {
                complete_timeout = 0;

                item.checked = true;
                item.completed_at = Util.get_default ().get_format_date (
                    new GLib.DateTime.now_local ()).to_string ();
                    
                if (item.project.todoist) {
                    checked_button.sensitive = false;
                    is_loading = true;
                    Services.Todoist.get_default ().complete_item.begin (item, (obj, res) => {
                        if (Services.Todoist.get_default ().complete_item.end (res)) {
                            Services.Database.get_default ().checked_toggled (item, old_checked);
                            is_loading = false;
                            checked_button.sensitive = true;
                        } else {
                            is_loading = false;
                            checked_button.sensitive = true;
                        }
                    });
                } else {
                    Services.Database.get_default ().checked_toggled (item, old_checked);
                }
                
                return GLib.Source.REMOVE;
            });
        } else {
            if (complete_timeout != 0) {
                GLib.Source.remove (complete_timeout);
                handle_grid.remove_css_class ("complete-animation");
                content_label.remove_css_class ("dim-label");
                content_label.remove_css_class ("line-through");
            } else {
                item.checked = false;
                item.completed_at = "";

                if (item.project.todoist) {
                    checked_button.sensitive = false;
                    is_loading = true;
                    Services.Todoist.get_default ().complete_item.begin (item, (obj, res) => {
                        if (Services.Todoist.get_default ().complete_item.end (res)) {
                            Services.Database.get_default ().checked_toggled (item, old_checked);
                            is_loading = false;
                            checked_button.sensitive = true;
                        }
                    });
                } else {
                    Services.Database.get_default ().checked_toggled (item, old_checked);
                }
            }
        }
    }

    public void update_content (string content = "") {
        content_textview.buffer.text = content;
    }

    public void update_priority (int priority) {
        item.priority = priority;
        
        if (is_creating) {
            priority_button.update_from_item (item);
        } else {
            item.update_async (Constants.INACTIVE, this);
        }
    }

    public void update_due (GLib.DateTime? datetime) {
        item.due.date = datetime == null ? "" : Util.get_default ().get_todoist_datetime_format (datetime);

        if (is_creating) {
            schedule_button.update_from_item (item);
        } else {
            item.update_async (Constants.INACTIVE, this);
        }
    }

    public void update_labels (Gee.HashMap <string, Objects.Label> labels) {
        if (is_creating) {
            item.update_local_labels (labels);
            item_labels.update_labels ();
        } else {
            item.update_labels_async (labels, this);
        }
    }

    public void delete_request () {
        if (item.project.todoist) {
            is_loading = true;
            Services.Todoist.get_default ().delete.begin (item, (obj, res) => {
                if (Services.Todoist.get_default ().delete.end (res)) {
                    Services.Database.get_default ().delete_item (item);
                } else {
                    is_loading = false;
                }
            });
        } else {
            Services.Database.get_default ().delete_item (item);
        }
    }

    //  public void move (int64 project_id, int64 section_id) {
    //      if (is_creating) {
    //          item.project_id = project_id;
    //          item.section_id = section_id;
    //          project_button.update_request ();
    //      } else {
    //          if (item.project_id != project_id || item.section_id != section_id) {
    //              if (item.project.todoist) {
    //                  is_loading = true;

    //                  int64 move_id = project_id;
    //                  string move_type = "project_id";
    //                  if (section_id != Constants.INACTIVE) {
    //                      move_type = "section_id";
    //                      move_id = section_id;
    //                  }

    //                  Planner.todoist.move_item.begin (item, move_type, move_id, (obj, res) => {
    //                      if (Planner.todoist.move_item.end (res)) {
    //                          move_item (project_id, section_id);
    //                          is_loading = false;
    //                      } else {
    //                          main_revealer.reveal_child = true;
    //                      }
    //                  });
    //              } else {
    //                  move_item (project_id, section_id);
    //              }
    //          }
    //      }
    //  }
}