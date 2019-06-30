using Gtk;
using Pango;

namespace Peeq.Utils {
    public class ValueCellRenderer : Gtk.CellRendererText {
        public ValueCellRenderer (string font) {
            this.font = font;
            this.editable = false;
            this.ellipsize = EllipsizeMode.END;
            this.ellipsize_set = true;
            this.size_points = 12;
        }
    }
}