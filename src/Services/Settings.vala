
namespace Peeq.Services {
	public class Settings : Granite.Services.Settings {
		public string[] servers { get; set; }

		public Settings ()  {
      base (Constants.PROJECT_NAME + ".settings");
		}
	}
}