/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.pattern
{
	public class Stock implements INotifier
	{
		private var _observers:Vector.<IObserver>;

		public function Stock()
		{
			_observers = new Vector.<IObserver>();
		}

		public function notify(observer:IObserver, command:int):void
		{
			_observers.forEach(function (element:IObserver, index:int, vec:Vector.<IObserver>):void
			{
				element.update(observer,command);
			});
		}

		public function attach(observer:IObserver):void
		{
			var index:int = _observers.indexOf(observer);
			if (index > -1) return;
			_observers.push(observer);
		}

		public function detach(observer:IObserver):void
		{
			var index:int = _observers.indexOf(observer);
			if (index < 0) return;
			_observers.splice(index, 1);
		}
	}
}
