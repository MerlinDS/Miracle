/**
 * User: MerlinDS
 * Date: 27.08.2014
 * Time: 13:41
 */
package com.merlinds.miracle.animations {
	import com.merlinds.miracle.geom.Transformation;

	/**
	 * Information that contains animation parameter for the frame
	 */
	public class FrameInfo{

		/** Name of the polygon in mesh for this frame.**/
		public var polygonName:String;
		/**
		 * Initial transformation. Can not be null.
		 */
		public var m0:Transformation;
		/**
		 * Terminal transformation. Can be null. Used for tween animation.
		 */
		public var m1:Transformation;
		/**
		 * Time factor for formula (1 - t)M0 - M1 * t < br/>
		 * Where M0 and M1 is Mesh matrix. Used only for tween animation.
		 */
		public var t:Number;

		public var isEmpty:Boolean;
		public var isMotion:Boolean;
		//==============================================================================
		//{region							PUBLIC METHODS

		/**
		 * Constructor
		 * @param polygonName Name of the polygon in mesh for this frame.
		 * @param m0 Start mesh matrix. Can not be null.
		 * @param m1 Finish mesh matrix. Can be null. Used for tween animation.
		 * @param t Time factor for formula (1 - t)M0 - M1 * t < br/>
		 */
		public function FrameInfo(polygonName:String, m0:Transformation, m1:Transformation = null, t:Number = 0) {
			this.polygonName = polygonName;
			this.m0 = m0;
			this.m1 = m1;
			this.t = t;
			if(this.polygonName == null && !isEmpty){
				throw new ArgumentError("Polygon name can not be null!");
			}
			if(this.m0 == null && !isEmpty){
				throw new ArgumentError("Start mesh matrix name can not be null!");
			}
			this.isMotion  = this.m1 != null;
		}

		public function toString():String {
			return isEmpty ? "[object EmptyFrameInfo]" :
					"[object FrameInfo (polygonName = " + this. polygonName + ", m0 = " + this.m0 + ", " +
					"m1 = " + this.m1 + ", t = " + this.t + ")]";
		}

		public function clone():FrameInfo {
			var clone:FrameInfo = new FrameInfo(this.polygonName, this.m0.clone(),
					this.m1 != null ? this.m1.clone() : null, this.t);
			clone.isEmpty = this.isEmpty;
			return clone;
		}

		public function dispose():void
		{
			if(this.m0 != null)this.m0.clear();
			if(this.m1 != null)this.m1.clear();
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
