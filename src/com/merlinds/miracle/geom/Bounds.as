package com.merlinds.miracle.geom
{
	public class Bounds
	{

		private static const _pool:Vector.<Bounds> = new <Bounds>[];

		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
//======================================================================================================================
//{region											PUBLIC METHODS
		public function Bounds(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0)
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}

		public static function getInstance():Bounds
		{
			return _pool.length > 0 ? _pool.pop() : new Bounds();
		}

		public function clone():Bounds
		{
			var clone:Bounds = getInstance();
			clone.updateBy(this);
			return clone;
		}

		[Inline]
		public final function updateBy(bounds:Bounds):void
		{
			this.x = bounds.x;
			this.y = bounds.y;
			this.width = bounds.width;
			this.height = bounds.height;
		}

		[Inline]
		public final function containsPoint(pointX:Number, pointY:Number,
											offsetX:Number, offsetY:Number):Boolean
		{
			var x:Number = this.x + offsetX;
			var y:Number = this.y + offsetY;
			return pointX >= x && pointY >= y
					&& pointX <= x + this.width && pointY <= y + this.height;
		}

		[Inline]
		public final function dispose():void
		{
			this.x = this.y = this.height = this.width = 0;
			if(_pool.indexOf(this) < 0)_pool.push(this);
		}
//} endregion PUBLIC METHODS ===========================================================================================
//======================================================================================================================
//{region										PRIVATE\PROTECTED METHODS

//} endregion PRIVATE\PROTECTED METHODS ================================================================================
//======================================================================================================================
//{region											GETTERS/SETTERS

//} endregion GETTERS/SETTERS ==========================================================================================

	}
}