/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 12:20
 */
package com.merlinds.miracle.format.mtf {
	import com.merlinds.miracle.format.*;
	public final class MTF1 extends MTFFile{

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MTF1() {
			super (Signatures.MTF1, "us-ascii");
			this.addHeader(2, 2, 1, "ATF");
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
