/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 18:49
 */
package com.merlinds.miracle.animations {
	import flash.errors.IllegalOperationError;

	/**
	 * List of frames type
	 */
	public class FrameType {

		/** Frame is empty **/
		public static const EMPTY:uint = 0x0;
		/** Frame is static **/
		public static const STATIC:uint = 0x1;
		/** Frame has motion **/
		public static const MOTION:uint = 0x2;
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor.
		 * @throw flash.errors.IllegalOperationError Object of this class can not be implemented
		 */
		public function FrameType() {
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
