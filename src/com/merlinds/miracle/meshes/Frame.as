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
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param matrixIndex Index of the mesh matrix in Layer transformations list.
		 * @param t Time factor for formula (1 - t)M0 - M1 * t < br/>
		 * Where M0 and M1 is Mesh matrix. Used only for tween animation.
		 *
		 * @see com.merlinds.miracle.meshes.Layer@transformations
		 */
		public function Frame(matrixIndex:int = -1, t:Number = 1) {
			this.matrixIndex = matrixIndex;
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
