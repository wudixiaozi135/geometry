/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.pattern
{
	public interface INotifier
	{
		function notify(msg:IObserver,command:int):void;
		function attach(observer:IObserver):void;
		function detach(observer:IObserver):void;
	}
}
