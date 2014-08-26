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

		//only for animation
		/** Name of the polygon in mesh.
		 *  <b>Used by animation calculation only.</b>
		**/
		public var polygonName:String;
		/** Animation type binary mask.
		 * <b>Used by animation calculation only.</b>
		 * Values:
		 * <ul>
		 *     <li>0 - static type animation. Nothing happens with animation matrix</li>
		 *     <li>1 - tween type animation. Calculate new mesh matrix by formula: (1 - t) * M0 - t * M1.
		 *     Where M0 and M1 are transformation matrix from the transformation list in Layer Object.
		 *     </li>
		 * </ul>
		 *
		 * @see com.merlinds.miracle.meshes.Layer@transformations
		 **/
		 public var animationType:uint;
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

		//==============================================================================
		//{region							PUBLIC METHODS
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
