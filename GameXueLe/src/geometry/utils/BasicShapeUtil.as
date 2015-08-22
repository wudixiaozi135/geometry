/**
 * Created by Administrator on 2015/7/24 0024.
 */
package geometry.utils
{
	import flash.geom.Point;

	import org.flexlite.domUI.core.UIComponent;

	public class BasicShapeUtil
	{
		public static function getRect(width:int=50,height:int=50,color:uint=0xBFC0C1,alpha:Number=1.0,border:int=0,borderColor:uint=0x0,name:String="rect"):UIComponent
		{
			var shape:UIComponent=new UIComponent();
			shape.name=name;
			shape.graphics.clear();
			shape.graphics.lineStyle(border,borderColor);
			shape.graphics.beginFill(color,alpha);
			shape.graphics.drawRect(0,0,width,height);
			shape.graphics.endFill();
			return shape;
		}

		public static function getCircle(radius:int=25,color:uint=0xBFC0C1,alpha:Number=1.0,border:int=0,borderColor:uint=0x0,name:String="circle"):UIComponent
		{
			var shape:UIComponent=new UIComponent();
			shape.name=name;
			shape.graphics.clear();
			shape.graphics.lineStyle(border,borderColor);
			shape.graphics.beginFill(color,alpha);
			shape.graphics.drawCircle(0,0,radius);
			shape.graphics.endFill();
			return shape;
		}

		public static function getTriangle(p1:Point,p2:Point,p3:Point,color:uint=0xBFC0C1,alpha:Number=1.0,border:int=0,borderColor:uint=0x0,name:String="rect"):UIComponent
		{
			var shape:UIComponent=new UIComponent();
			shape.name=name;
			var vertices:Vector.<Number> = new Vector.<Number>();
			vertices.push(p1.x,p1.y);
			vertices.push(p2.x,p2.y);
			vertices.push(p3.x,p3.y);

			shape.graphics.clear();
			shape.graphics.lineStyle(border,borderColor);
			shape.graphics.beginFill(color,alpha);
			shape.graphics.drawTriangles(vertices);
			shape.graphics.endFill();
			return shape;
		}

	}
}
