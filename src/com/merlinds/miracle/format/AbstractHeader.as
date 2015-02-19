/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 13:53
 */
package com.merlinds.miracle.format {

	/**
	 * Class contains information about file header.
	 * This is abstract class for MAFHeader and MTFHeader.
	 * Do not instantiate it.
	 *
	 * @see com.merlinds.miracle.format.maf.MAFHeader
	 * @see com.merlinds.miracle.format.mtf.MTFHeader
	 */
	public class AbstractHeader {

		public var verticesSize:int;
		public var modificationDate:Number;
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * This is abstract class. Do not instantiate it!
		 */
		public function AbstractHeader() {

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
		protected function get formattedDate():String {
			var date:Date = new Date();
			date.setTime(this.modificationDate);
			return date.toUTCString();
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
