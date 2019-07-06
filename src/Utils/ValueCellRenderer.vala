using Gtk;
using Pango;

namespace Peeq.Utils {
    public class ValueCellRenderer : Gtk.CellRendererText {
        public ValueCellRenderer (string font, string size) {
            this.font = font;
            this.size_points = int.parse(size);
            this.editable = true;
            this.ellipsize = EllipsizeMode.END;
            this.ellipsize_set = true;
        }
    }
}