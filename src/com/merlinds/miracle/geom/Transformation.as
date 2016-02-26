/**
 * User: MerlinDS
 * Date: 12.09.2014
 * Time: 18:36
 */
package com.merlinds.miracle.geom
{

	import flash.geom.Rectangle;

	public class Transformation
	{
		public var matrix:TransformMatrix;
		public var color:Color;
		public var bounds:Rectangle;
		//==============================================================================
		//{region							PUBLIC METHODS

		public function Transformation(matrix:TransformMatrix = null, color:Color = null, bounds:Rectangle = null)
		{
			this.matrix = matrix;
			this.color = color;
			this.bounds = bounds;
		}

		public function clear():void
		{
			if(this.matrix != null)this.matrix.clear();
			if(this.color != null)this.color.clear();
			if(this.bounds != null)this.bounds.setEmpty();
		}

		public function clone():Transformation
		{
			var matrix:TransformMatrix = this.matrix == null ? null : new TransformMatrix(this.matrix.offsetX, this.matrix.offsetY,
					this.matrix.tx, this.matrix.ty, this.matrix.scaleX, this.matrix.scaleY, this.matrix.skewX, this.matrix.skewY);
			var color:Color = this.color == null ? null : new Color(this.color.redMultiplier, this.color.greenMultiplier,
					this.color.blueMultiplier, this.color.alphaMultiplier,
					this.color.redOffset, this.color.greenOffset, this.color.blueOffset, this.color.alphaOffset);
			var bounds:Rectangle = this.bounds == null ? null : this.bounds.clone();
			return new Transformation(matrix, color, bounds);
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
