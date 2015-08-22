/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.ui
{
	import flash.display.Graphics;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.core.UIComponent;

	public class PenUI extends Group
	{
		public static const PEN_STYLE_GREEN:int=0;
		public static const PEN_STYLE_RED:int=1;

		private var _greenLine:UIComponent;
		private var _redLine:UIComponent;

		public function PenUI()
		{
			super();
			_greenLine = new UIComponent();
			addElement(_greenLine);
			_redLine = new UIComponent();
			addElement(_redLine);
		}

		/*
		 * @param style 0:默认绿线 1为红线
		 * */
		public function drawLine(startX:Number, startY:Number, endX:Number, endY:Number, style:int = 0):void
		{
			var pen:Graphics,color:uint;
			if (style == PEN_STYLE_GREEN)
			{
				pen = _greenLine.graphics;
				color=0x00ff00;
			} else if (style == PEN_STYLE_RED)
			{
				pen = _redLine.graphics;
				color=0xff0000;
			}
			if (pen != null)
			{
				with (pen)
				{
					clear();
					lineStyle(2, color);
					moveTo(startX, startY);
					lineTo(endX, endY);
				}
			}
		}

		/*
		 * @param style 0:默认绿线 1为红线
		 * */
		public function clear(style:int = 0):void
		{
			if (style == PEN_STYLE_GREEN)
			{
				_greenLine.graphics.clear();
			} else if (style == PEN_STYLE_RED)
			{
				_redLine.graphics.clear();
			}
		}

		private static var _instance:PenUI = null;

		public static function get getInstance():PenUI
		{
			if (_instance == null)
			{
				_instance = new PenUI();
			}
			return _instance;
		}
	}
}
