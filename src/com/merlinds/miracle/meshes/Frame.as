/**
 * User: MerlinDS
 * Date: 26.08.2014
 * Time: 16:53
 */
package com.merlinds.miracle.meshes {
	/**
	 * Frame description
	**/
	public class Frame {
		public static const STATIC:uint = 0;
		public static const TWEEN:int = 1;
		/**
		 * Index of the mesh matrix in Layer transformations list.
		 * @see com.merlinds.miracle.meshes.Layer@transformations
		 */
		public var matrixIndex:int;
		/**
		 * Time factor for formula (1 - t)M0 - M1 * t < br/>
		 * Where M0 and M1 is Mesh matrix. Used only for tween animation.
		 */
		public var t:Number;
		/** Name of the polygon in mesh for this frame.**/
		public var polygonName:String;
		/** Animation type binary mask.
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
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param matrixIndex Index of the mesh matrix in Layer transformations list.
		 * @param polygonName Name of the polygon in mesh for this frame.
		 * @param animationType Animation type binary mask.
		 * Values:
		 * <ul>
		 *     <li>0 - static type animation. Nothing happens with animation matrix</li>
		 *     <li>1 - tween type animation. Calculate new mesh matrix by formula: (1 - t) * M0 - t * M1.
		 *     Where M0 and M1 are transformation matrix from the transformation list in Layer Object.
		 *     </li>
		 * </ul>
		 * @param t Time factor for formula (1 - t)M0 - M1 * t < br/>
		 * Where M0 and M1 is Mesh matrix. Used only for tween animation.
		 *
		 * @see com.merlinds.miracle.meshes.Layer@transformations
		 */
		public function Frame(matrixIndex:int = -1, polygonName:String = null, animationType:int = 0, t:Number = 1) {
			this.matrixIndex = matrixIndex;
			this.polygonName = polygonName;
			this.animationType = animationType;
			this.t = t;
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
