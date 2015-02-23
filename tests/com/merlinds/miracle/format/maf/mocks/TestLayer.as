/**
 * User: MerlinDS
 * Date: 23.02.2015
 * Time: 17:04
 */
package com.merlinds.miracle.format.maf.mocks {
	import com.merlinds.miracle.geom.Transformation;

	public class TestLayer {
		public var frames:Vector.<TestFrame>;
		public var matrix:Vector.<Transformation>;
		public var polygons:Vector.<String>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function TestLayer() {
			this.frames = new <TestFrame>[];
			this.matrix = new <Transformation>[];
			this.polygons = new <String>[];
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
