/**
 * User: MerlinDS
 * Date: 25.08.2014
 * Time: 16:15
 */
package com.merlinds.miracle.meshes {
	/**
	 * Object for animation format.
	 * Contains animation parameters, all transformations for meshes.
	 */
	public class Animation {

		/**
		 * Name of the animation.
		 * WARNING: Can be removed
		 */
		public var name:String;
		/** Total count of frames in animation **/
		public var totalFrames:int;
		/** Layers on the animation. **/
		public var layers:Vector.<Layer>;

		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param name Animation name
		 * @param totalFrames Total count of frames. At least 1
		 *
		 * @throws ArgumentError if Total count of frames will be less than one
		 */
		public function Animation(name:String, totalFrames:int = 1) {
			this.name = name;
			this.totalFrames = totalFrames;
			if(this.totalFrames < 1){
				throw new ArgumentError("Must be at least one frame for animation!");
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
