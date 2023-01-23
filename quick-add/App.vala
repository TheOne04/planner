public class QuickAdd : Adw.Application {
    public MainWindow main_window;

    public static GLib.Settings settings;

    public static QuickAdd _instance = null;
    public static QuickAdd instance {
        get {
            if (_instance == null) {
                _instance = new QuickAdd ();
            }
            return _instance;
        }
    }
    
    static construct {
        settings = new Settings ("com.github.alainm23.planit");
    }

    construct {
        application_id = "com.github.alainm23.planner.quick-add";
        flags |= ApplicationFlags.HANDLES_OPEN;

        Intl.setlocale (LocaleCategory.ALL, "");
        string langpack_dir = Path.build_filename (Constants.INSTALL_PREFIX, "share", "locale");
        Intl.bindtextdomain (Constants.GETTEXT_PACKAGE, langpack_dir);
        Intl.bind_textdomain_codeset (Constants.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Constants.GETTEXT_PACKAGE);
    }

    protected override void activate () {
        main_window = new MainWindow (this);
        main_window.show ();
        
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/alainm23/planner/index.css");
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        Util.get_default ().update_theme ();
    }

    public static int main (string[] args) {
        QuickAdd app = QuickAdd.instance;
        return app.run (args);
    }
}