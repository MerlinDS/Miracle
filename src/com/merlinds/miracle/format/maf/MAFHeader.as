/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 13:51
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.format.AbstractHeader;

	/**
	 * Instance of this class contains information of the MAF file header
	 */
	public class MAFHeader extends AbstractHeader{

		public var matrixSize:int;
		public var frameSize:int;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFHeader() {
		}

		public function toString():String {
			return "[MTFHeader(" +
					"verticesSize = " + this.verticesSize + " " +
					"matrixSize = " + this.matrixSize + " " +
					"frameSize = " + this.frameSize + " " +
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
