/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 21:50
 */
package com.merlinds.miracle.utils {
	import flash.utils.ByteArray;

	public class Asset {
		public var name:String;
		public var bytes:ByteArray;
		public var data:Array;

		//==============================================================================
		//{region							PUBLIC METHODS

		public function Asset(name:String, bytes:ByteArray, data:Array) {
			this.name = name;
			this.bytes = bytes;
			this.data = data;
		}

		public function destroy():void {
			this.name = null;
			this.bytes = null;
			this.data = null;
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
