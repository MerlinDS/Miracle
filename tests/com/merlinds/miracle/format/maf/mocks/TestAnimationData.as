/**
 * User: MerlinDS
 * Date: 23.02.2015
 * Time: 17:03
 */
package com.merlinds.miracle.format.maf.mocks {
	import flash.geom.Rectangle;

	public class TestAnimationData {
		public var name:String;
		public var bounds:Rectangle;
		public var layers:Vector.<TestLayer>;
		public var totalFrames:int;
		public var polygonsCount:int;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function TestAnimationData(name:String, bouds:Rectangle) {
			this.name = name;
			this.bounds = bouds;
			this.layers = new <TestLayer>[];
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
