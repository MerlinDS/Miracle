/**
 * User: MerlinDS
 * Date: 23.02.2015
 * Time: 17:05
 */
package com.merlinds.miracle.format.maf.mocks {
	public class TestFrame {
		public var polygonName:String;
		public var type:uint;
		public var matrixIndex:int;
		public var t:Number;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function TestFrame(polygonName:String, type:uint, matrixIndex:int, t:Number) {
			this.polygonName = polygonName;
			this.type = type;
			this.matrixIndex = matrixIndex;
			this.t = t;
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
