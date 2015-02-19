/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 19:20
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.format.Signatures;

	public class MAF1 extends MAFFile{

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAF1() {
			super (Signatures.MAF1, "us-ascii");
			this.addHeader(32, 18, 10);
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
