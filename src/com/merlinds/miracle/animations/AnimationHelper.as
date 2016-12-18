/**
 * User: MerlinDS
 * Date: 27.08.2014
 * Time: 13:48
 */
package com.merlinds.miracle.animations {

	import com.merlinds.miracle.geom.Bounds;

	/**
	 * Object for animation format.
	 * Contains animation parameters, all transformations for polygon.
	 */
	public class AnimationHelper {
		/**
		 * Name of the animation.
		 * WARNING: Can be removed
		 */
//		public var name:String;
		/** Total count of frames in animation **/
		public var totalFrames:int;
		/** Number of layers **/
		public var numLayers:int;
		/** Frames on the animation. Rectangular array**/
		public var frames:Vector.<FrameInfo>;
		public var bounds:Bounds;
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param name Animation name
		 * @param totalFrames Total count of frames. At least 1
		 * @param numLayers Number of layers
		 * @param frames List of the frames description
		 *
		 * @see com.merlinds.miracle.animations.FrameInfo
		 * @throws ArgumentError if Total count of frames will be less than one
		 * @throws ArgumentError if Total count of frames will be bigger than frames list length
		 */
		public function AnimationHelper(totalFrames:int, numLayers:int, frames:Vector.<FrameInfo> = null) {
			if(frames.length < totalFrames){
				throw new ArgumentError("Length of frames can not be less than totalFrames count!");
			}
			if(totalFrames < 1){
				throw new ArgumentError("Must be at least one frame for animation!");
			}
//			this.name = name;
			this.frames = frames;
			this.numLayers = numLayers;
			this.totalFrames = totalFrames;
		}

		public function clone():AnimationHelper {
			var frames:Vector.<FrameInfo> = new <FrameInfo>[];
			var n:int = frames.length = this.frames.length;
			for(var i:int = 0; i < n; i++){
				frames[i] = this.frames[i].clone();
			}
			var clone:AnimationHelper = new AnimationHelper(this.totalFrames, this.numLayers, frames);
			clone.bounds = this.bounds.clone();
			return clone;
		}

		public function dispose():void
		{
			if(this.frames != null)
			{
				while (this.frames.length > 0)
					this.frames.pop().dispose();
			}
			this.bounds.dispose();
			this.bounds = null;
			this.frames = null;
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
