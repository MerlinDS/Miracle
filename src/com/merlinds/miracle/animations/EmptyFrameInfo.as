/**
 * User: MerlinDS
 * Date: 26.09.2014
 * Time: 16:16
 */
package com.merlinds.miracle.animations {
	public class EmptyFrameInfo extends FrameInfo{

		private static const _instance:EmptyFrameInfo = new EmptyFrameInfo();
		//==============================================================================
		//{region							PUBLIC METHODS
		public function EmptyFrameInfo() {
			this.isEmpty = true;
			super (null, null);
		}

		public static function getConst():EmptyFrameInfo
		{
			return _instance;
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
