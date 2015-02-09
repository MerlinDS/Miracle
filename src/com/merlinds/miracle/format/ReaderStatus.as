/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 12:02
 */
package com.merlinds.miracle.format {
	import flash.errors.IllegalOperationError;

	/**
	 * Status of the format reader instance
	 */
	public class ReaderStatus {

		/** Format reader is waiting for input **/
		public static const WAIT:uint = 0x0;
		/** Format reader is in process of reading input **/
		public static const PROCESSING:uint = 0x2;
		/** Output of format reader is ready to use **/
		public static const READY:uint = 0x4;
		/** Error has occurred while reading **/
		public static const ERROR:uint = 0x8;
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor.
		 * @throw flash.errors.IllegalOperationError Object of this class can not be implemented
		 */
		public function ReaderStatus() {
			throw new IllegalOperationError("Object of this class can not be implemented");
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
