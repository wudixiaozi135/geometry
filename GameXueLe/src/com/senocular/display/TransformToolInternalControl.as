/**
 * Created by Administrator on 2015/8/5.
 */
package com.senocular.display
{
	import flash.events.Event;
	import flash.geom.Point;

	import org.flexlite.domUI.core.UIComponent;

	public class TransformToolInternalControl extends TransformToolControl {

		public var interactionMethod:Function;
		public var referenceName:String;
//	public var _skin:DisplayObject;
		public var _skin:UIComponent;

		public function set skin(skin:UIComponent):void {
			if (_skin && contains(_skin)) {
//			removeChild(_skin);
				removeElement(_skin);
			}
			_skin = skin;
			if (_skin) {
//			addChild(_skin);
				addElement(_skin);
			}
			draw();
		}

		public function get skin():UIComponent {
			return _skin;
		}

		override public function get referencePoint():Point {
			if (referenceName in _transformTool) {
				return _transformTool[referenceName];
			}
			return null;
		}

		/*
		 * Constructor
		 */
		public function TransformToolInternalControl(name:String, interactionMethod:Function = null, referenceName:String = null) {
			this.name = name;
			this.interactionMethod = interactionMethod;
			this.referenceName = referenceName;
			addEventListener(TransformTool.CONTROL_INIT, init);
		}

		protected function init(event:Event):void {
			_transformTool.addEventListener(TransformTool.NEW_TARGET, draw);
			_transformTool.addEventListener(TransformTool.TRANSFORM_TOOL, draw);
			_transformTool.addEventListener(TransformTool.CONTROL_TRANSFORM_TOOL, position);
			_transformTool.addEventListener(TransformTool.CONTROL_PREFERENCE, draw);
			_transformTool.addEventListener(TransformTool.CONTROL_MOVE, controlMove);
			draw();
		}

		public function draw(event:Event = null):void {
			if (_transformTool.maintainControlForm) {
				counterTransform();
			}
			position();
		}

		public function position(event:Event = null):void {
			var reference:Point = referencePoint;
			if (reference) {
				x = reference.x;
				y = reference.y;
			}
		}

		private function controlMove(event:Event):void {
			if (interactionMethod && _transformTool.currentControl == this) {
				interactionMethod();
			}
		}
	}
}
