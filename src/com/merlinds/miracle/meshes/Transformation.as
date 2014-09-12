/**
 * User: MerlinDS
 * Date: 12.09.2014
 * Time: 18:36
 */
package com.merlinds.miracle.meshes {
	import flash.geom.Rectangle;

	public class Transformation {

		public var matrix:TransformMatrix;
		public var color:Color;
		public var bounds:Rectangle;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function Transformation(matrix:TransformMatrix = null, color:Color = null, bounds:Rectangle = null) {
			this.matrix = matrix;
			this.color = color;
			this.bounds = bounds;
		}

		public function clear():void{

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
