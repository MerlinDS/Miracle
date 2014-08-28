/**
 * User: MerlinDS
 * Date: 27.08.2014
 * Time: 13:41
 */
package com.merlinds.miracle.animations {
	import com.merlinds.miracle.meshes.MeshMatrix;

	/**
	 * Information that contains animation parameter for the frame
	 */
	public class FrameInfo {
		/** Name of the polygon in mesh for this frame.**/
		public var polygonName:String;
		/**
		 * Start mesh matrix. Can not be null.
		 */
		public var m0:MeshMatrix;
		/**
		 * Finish mesh matrix. Can be null. Used for tween animation.
		 */
		public var m1:MeshMatrix;
		/**
		 * Time factor for formula (1 - t)M0 - M1 * t < br/>
		 * Where M0 and M1 is Mesh matrix. Used only for tween animation.
		 */
		public var t:Number;
		//==============================================================================
		//{region							PUBLIC METHODS

		/**
		 * Constructor
		 * @param polygonName Name of the polygon in mesh for this frame.
		 * @param m0 Start mesh matrix. Can not be null.
		 * @param m1 Finish mesh matrix. Can be null. Used for tween animation.
		 * @param t Time factor for formula (1 - t)M0 - M1 * t < br/>
		 */
		public function FrameInfo(polygonName:String, m0:MeshMatrix, m1:MeshMatrix = null, t:Number = 0) {
			this.polygonName = polygonName;
			this.m0 = m0;
			this.m1 = m1;
			this.t = t;
			if(this.polygonName == null){
				throw new ArgumentError("Polygon name can not be null!");
			}
			if(this.m0 == null){
				throw new ArgumentError("Start mesh matrix name can not be null!");
			}
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
