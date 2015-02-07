/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 9:51
 */
package com.merlinds.miracle.formatreaders {
	import flash.errors.IllegalOperationError;

	internal class ControlCharacters {

		/**
		 * Contained constants with available controls characters from ASCII table
		 */
		//==============================================================================
		//{region							PUBLIC METHODS
		/** End of file **/
		public static const EOF:uint = 0x0;
		/** End of transmission. Used for texture block separation **/
		public static const EOT:uint = 0x04;
		/** End of text block **/
		public static const ETB:uint = 0x17;
		/** Data link escape. Used for data block separation **/
		public static const DLE:uint = 0x10;
		/** Group separator **/
		public static const GS:uint = 0x1D;
		/** Record separator **/
		public static const RS:uint = 0xE;
		/** Unit separator **/
		public static const US:uint = 0x1F;

		/**
		 * Constructor.
		 * @throw flash.errors.IllegalOperationError Object of this class can not be implemented
		 */
		public function ControlCharacters() {
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
