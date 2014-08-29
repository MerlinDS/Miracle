/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 21:07
 */
package com.merlinds.miracle.meshes {
	/**
	 * Helper for drawing and animation calculation
	**/
	public class MeshMatrix {

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

		public var color:Array;

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
		public function MeshMatrix(offsetX:Number = 0, offsetY:Number = 0, tx:Number = 0, ty:Number = 0,
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
		}
		public static function fromObject(object:Object):MeshMatrix {
			var meshMatrix:MeshMatrix = new MeshMatrix(
				object.offsetX, object.offsetY, object.tx, object.ty,
				object.scaleX, object.scaleY, object.skewX, object.skewY
			);
			return meshMatrix;
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
