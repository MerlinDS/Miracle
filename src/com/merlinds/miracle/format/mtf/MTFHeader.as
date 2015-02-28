/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:37
 */
package com.merlinds.miracle.format.mtf {
	import com.merlinds.miracle.format.AbstractHeader;

	/**
	 * Object of this class contains information of the MTF file header
	 */
	internal class MTFHeader extends AbstractHeader{

		public var uvsSize:int;
		public var indexesSize:int;
		public var textureFormat:String;
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}