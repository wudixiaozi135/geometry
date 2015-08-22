/**
 * Created by Administrator on 2015/8/5.
 */
package com.senocular.display
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.flexlite.domUI.core.UIComponent;

	public class TransformToolMoveShape extends TransformToolInternalControl {

		private var lastTarget:UIComponent;

		function TransformToolMoveShape(name:String, interactionMethod:Function) {
			super(name, interactionMethod);
		}

		override public function draw(event:Event = null):void {

			var currTarget:UIComponent;
			var moveUnderObjects:Boolean = _transformTool.moveUnderObjects;

			// use hitArea if moving under objects
			// then movement would have the same depth as the tool
			if (moveUnderObjects) {
				hitArea = _transformTool.target as Sprite;
				currTarget = null;
				relatedObject = this;

			}else{

				// when not moving under objects
				// use the tool target to handle movement allowing
				// objects above it to be selectable
				hitArea = null;
				currTarget = _transformTool.target;
				relatedObject = _transformTool.target as InteractiveObject;
			}

			if (lastTarget != currTarget) {
				// set up/remove listeners for target being clicked
				if (lastTarget) {
					lastTarget.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false);
				}
				if (currTarget) {
					currTarget.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
				}

				// register/unregister cursor with the object
				var cursor:TransformToolCursor = _transformTool.moveCursor;
				cursor.removeReference(lastTarget);
				cursor.addReference(currTarget);

				lastTarget = currTarget;
			}
		}

		private function mouseDown(event:MouseEvent):void {
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
	}

}
