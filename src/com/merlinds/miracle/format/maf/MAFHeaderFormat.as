/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 16:28
 */
package com.merlinds.miracle.format.maf {
	import flash.errors.IllegalOperationError;

	public class MAFHeaderFormat {

		//4 bytes offset for signature
		//Data types
		/** Position of description of transformation matrix size (2 bytes)**/
		public static const MT:int = 4;
		/** Position of description of transformation color size (2 bytes)**/
		public static const CT:int = 6;
		/** Position of description of frame size (2 bytes)**/
		public static const FT:int = 8;
		/** Position of descriptor of modification date (4 bytes)**/
		public static const DATE:int = 10;
		/**Size of the header in bytes **/
		public static const HEADER_SIZE:int = DATE + 4;//Last pointer + pointer size

		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor.
		 * @throw flash.errors.IllegalOperationError Object of this class can not be implemented
		 */
		public function MAFHeaderFormat() {
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
