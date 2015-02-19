/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 18:46
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.format.FormatFile;

	public class MAFFile extends FormatFile {

		private var _header:MAFHeader;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFFile(signature:String, charSet:String) {
			super(signature, charSet);
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
