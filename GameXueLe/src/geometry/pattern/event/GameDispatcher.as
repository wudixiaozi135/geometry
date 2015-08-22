/**
 * Created by Administrator on 2015/7/24 0024.
 */
package geometry.pattern.event
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class GameDispatcher
	{
		private static var _dispatcher:EventDispatcher = new EventDispatcher();

		public function GameDispatcher()
		{
			throw new Error("can't instance");
		}

		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

		public static function dispatchEvent(type:String,param:Object=null):Boolean
		{
			return _dispatcher.dispatchEvent(new GameEvent(type,param));
		}

		public static function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}

		public static function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}
}
