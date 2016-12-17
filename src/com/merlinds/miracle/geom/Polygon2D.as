/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:39
 * Coied form com.salazkin.framework.Shape
 */
package com.merlinds.miracle.geom {
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class Polygon2D {

		public static const BUFFER_SIZE:int = 4 * 4;//4 field * 4 bytes

		public var indexes:Vector.<int>;
		public var buffer:ByteArray;
		public var numVertices:Number;

		public function Polygon2D(indexes:Vector.<int>, numVertices:Number) {
			this.indexes = indexes;
			this.numVertices = numVertices;
			this.buffer = new ByteArray();
		}

		//==============================================================================
		//{region							PUBLIC METHODS
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
