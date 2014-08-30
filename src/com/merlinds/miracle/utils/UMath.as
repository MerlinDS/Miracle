/**
 * User: MerlinDS
 * Date: 29.08.2014
 * Time: 19:00
 */
package com.merlinds.miracle.utils {
	public class UMath {
		public function UMath() {
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public static function shortestAngle(a:Number, b:Number):Number {
			return Math.atan2( Math.sin(a - b), Math.cos(a - b) );
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
