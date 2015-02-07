/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:37
 */
package com.merlinds.miracle.formatreaders {
	/**
	 * Object of this class contains information of the MTF file header
	 */
	public class MTFHeader {

		public var verticesSize:int;
		public var uvsSize:int;
		public var indexesSize:int;
		public var textureFormat:String;
		public var modificationDate:Number;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MTFHeader() {
		}

		public function toString():String {
			return "[MTFHeader(" +
					"verticesSize = " + this.verticesSize + " " +
					"uvsSize = " + this.uvsSize + " " +
					"indexesSize = " + this.indexesSize + " " +
					"textureFormat = " + this.textureFormat + " " +
					"modificationDate = " + this.formattedDate +
					")]";
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
		private function get formattedDate():String {
			var date:Date = new Date();
			date.setTime(this.modificationDate);
			return date.toUTCString();
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
