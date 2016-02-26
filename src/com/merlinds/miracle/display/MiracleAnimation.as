/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 18:30
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.events.MiracleEvent;
	import com.merlinds.miracle.miracle_internal;

	/**
	 * Will be dispatched when loop flag set as false and playback is complete
	 */
	[Event(type="com.merlinds.miracle.events.MiracleEvent", name="playbackComplete")]
	/**
	 * Main miracle animation class
	 */
	public class MiracleAnimation extends MiracleDisplayObject{

		use namespace miracle_internal;

		private var _loop:Boolean;
		private var _prevPlaybackDirection:int;
		private var _fps:int;
		miracle_internal var playbackDirection:int;
		miracle_internal var frameDelta:Number;
		miracle_internal var timePassed:Number;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleAnimation() {
			super();
			_prevPlaybackDirection = playbackDirection = 1;
			_isAnimated = true;
			_loop = true;
			this.fps = 60;//Default frame rate
		}

		/** Stop animation immediately **/
		public function stop():void {
			_prevPlaybackDirection = playbackDirection;
			playbackDirection = 0;
		}

		/** Start play animation **/
		public function play():void {
			this.currentFrame = 0;
			playbackDirection = 1;
		}

		/**
		 *  Revert animation playing
		 * @param autoPlay If autoPlay flag equals true, than animation will be played immediately.
		 **/
		public function revert(autoPlay:Boolean = true):void {
			if(playbackDirection == 0)
				playbackDirection = _prevPlaybackDirection;
			playbackDirection = ~playbackDirection + 1;
			if(!autoPlay)this.stop();
		}

		miracle_internal function stopPlayback():void{
			if(onStage){
				this.stop();
				if(this.hasEventListener(MiracleEvent.PLAYBACK_COMPLETE)){
					this.dispatchEvent(new MiracleEvent(MiracleEvent.PLAYBACK_COMPLETE));
				}
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS

		override protected function afterRemove():void {
			playbackDirection = 0;
			 _prevPlaybackDirection = 1;
		}

		override miracle_internal function dispose():void
		{
			_loop = false;
			frameDelta = timePassed = 0;
			playbackDirection  = _prevPlaybackDirection =_fps = 0;
			super.miracle_internal::dispose();
		}

//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//end of transformations
		//playback

		public override function set currentFrame(value:int):void {
			if(playbackDirection != 0)super .currentFrame = value;
		}

		public function get fps():int {
			return _fps;
		}

		public function set fps(value:int):void {
			_fps = value;
			miracle_internal::frameDelta = 1000 / value;
			miracle_internal::timePassed = 0;
		}

		public function get loop():Boolean {
			return _loop;
		}

		public function set loop(value:Boolean):void {
			_loop = value;
		}

		public function get onPause():Boolean {
			return playbackDirection == 0;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
