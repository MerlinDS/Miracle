/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 21:07
 */
package com.merlinds.miracle.geom {
	//TODO MF-34 Add commentaries to geom folder
	/**
	 * Helper for drawing and animation calculation
	**/
	public class TransformMatrix {

		//general
		/** scale by X **/
		public var scaleX:Number;
		/** scale by Y **/
		public var scaleY:Number;
		/** skew by X **/
		public var skewX:Number;
		/** skew by Y **/
		public var skewY:Number;
		/** move by X **/
		public var tx:Number;
		/** move by Y **/
		public var ty:Number;
		/** offset by X **/
		public var offsetX:Number;
		/** offset by Y **/
		public var offsetY:Number;

		public var flipX:int;
		/** Color transformation object**/
		//TODO: MF-36 Add type bynary mask to MeshMatrix
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 *
		 * @param scaleX Scale by X
		 * @param scaleY Scale by Y
		 * @param skewX Skew by X
		 * @param skewY Skew by Y
		 * @param tx Move by X
		 * @param ty Move by Y
		 * @param offsetX Offset by X
		 * @param offsetY Offset by Y
		 */
		public function TransformMatrix(offsetX:Number = 0, offsetY:Number = 0, tx:Number = 0, ty:Number = 0,
		                              scaleX:Number = 1, scaleY:Number = 1, skewX:Number = 0, skewY:Number = 0
		                              ) {
			this.offsetX = offsetX;
			this.offsetY = offsetY;
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.skewX = skewX;
			this.skewY = skewY;
			this.tx = tx;
			this.ty = ty;
			this.flipX = 1;
		}

		public function toString():String {
			return "[MeshMatrix( offsetX = " + this.offsetX + ", offsetY = " + this.offsetY +
					", tx = " + this.tx + ", ty = , " + this.ty  +
					", scaleX = " + this.scaleX + ", scaleY = " + this.scaleY  +
					", skewX = " + this.skewX + ", skewY  = " + this.skewY + ")]";
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
