/**
 * Created by Administrator on 2015/8/5.
 */
package geometry.manager
{
	public class MouseTargetManager
	{
		public static var currentTarget:*;
		public static var target:*;
		public function MouseTargetManager()
		{
		}

		private static var _instance:MouseTargetManager = null;

		public static function get getInstance():MouseTargetManager
		{
			if (_instance == null)
			{
				_instance = new MouseTargetManager();
			}
			return _instance;
		}
	}
}
