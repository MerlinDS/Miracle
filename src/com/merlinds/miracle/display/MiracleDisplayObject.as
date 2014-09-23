/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 20:56
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.events.MiracleEvent;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.miracle_internal;

	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	[Event(type="com.merlinds.miracle.events.MiracleEvent", name="addedToStage")]
	public class MiracleDisplayObject extends EventDispatcher{

		use namespace miracle_internal;

		miracle_internal var frameDelta:Number;
		miracle_internal var timePassed:Number;

		/**
		 * Name of the mesh that will be used
		 */
		public var mesh:String;
		/**
		 * Name of the timeline that will be used
		 */
		private var _animation:String;

		private var _fps:int;
		private var _currentFrame:int;
		//Transformations
		public var transformation:Transformation;
		//Playback
		private var _onStage:Boolean;
		private var _onPause:Boolean;
		private var _loop:Boolean;

		public function MiracleDisplayObject() {
			this.transformation = new Transformation( new TransformMatrix(), new Color(), new Rectangle());
			this.fps = 60;//Default frame rate
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		/** Stop animation immediately **/
		public function stop():void {
			_onPause = true;
		}

		/** Start play animation **/
		public function play():void {
			_onPause = false;
		}

		/** Revert animation playing **/
		public function revert():void {

		}

		public function hitTest(point:Point):Boolean {
			//temp
			var rect:Rectangle = this.transformation.bounds.clone();
			rect.offset(this.transformation.matrix.tx, this.transformation.matrix.ty);
			return rect.containsPoint(point);
		}
		/**
		 * move instance to new coordinates
		 * @param x
		 * @param y
		 * @param z
		 * @return Current instance
		 */
		public function moveTO(x:Number = 0, y:Number = 0, z:Number = 0):MiracleDisplayObject {
			this.transformation.matrix.tx = x;
			this.transformation.matrix.ty = y;
			//TODO MF-41 Add z-index sorting
			return this;
		}

		miracle_internal function drawn():void{
			if(!_onStage){
				//After first draw dispatch event that display object was added to stage
				if(this.hasEventListener(MiracleEvent.ADDED_TO_STAGE)){
					this.dispatchEvent(new MiracleEvent(MiracleEvent.ADDED_TO_STAGE));
				}
				_onStage = true;
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
		[Inline]
		public final function get animation():String {
			return _animation;
		}

		[Inline]
		public final function set animation(value:String):void {
			_animation = value;
			_currentFrame = 0;
		}
		//Transformations
		public function get width():int {
			return this.transformation.bounds.width;
		}

		public function get height():int {
			return this.transformation.bounds.height;
		}

		public function get x():Number {
			return this.transformation.matrix.tx;
		}

		public function set x(value:Number):void {
			this.transformation.matrix.tx = value;
		}

		public function get y():Number {
			return this.transformation.matrix.ty;
		}

		public function set y(value:Number):void {
			this.transformation.matrix.ty = value;
		}

		public function get z():Number {
			//TODO MF-41 Add z-index sorting
			return 0;
		}

		public function set z(value:Number):void {
			//TODO MF-41 Add z-index sorting
		}

		public function get scaleX():Number {
			return this.transformation.matrix.scaleX;
		}

		public function set scaleX(value:Number):void {
			//TODO MF-47 Change DisplayObject instance bounds by new transformation
			this.transformation.matrix.scaleX = value;
		}

		public function get scaleY():Number {
			return this.transformation.matrix.scaleY;
		}

		public function set scaleY(value:Number):void {
			//TODO MF-47 Change DisplayObject instance bounds by new transformation
			this.transformation.matrix.scaleY = value;
		}

		public function get skewX():Number {
			return this.transformation.matrix.skewX;
		}

		public function set skewX(value:Number):void {
			//TODO MF-47 Change DisplayObject instance bounds by new transformation
			this.transformation.matrix.skewX = value;
		}

		public function get skewY():Number {
			return this.transformation.matrix.skewY;
		}

		public function set skewY(value:Number):void {
			//TODO MF-47 Change DisplayObject instance bounds by new transformation
			this.transformation.matrix.skewY = value;
		}

		public function get alpha():Number {
			//revert alphaMultiplier to alpha value
			return 1 - this.transformation.color.alphaMultiplier;
		}

		public function set alpha(value:Number):void {
			//fix value if it not in 0 1 diapason
			value = value > 1 ? 1: value < 0 ? 0 : value;
			value = 1 - value;//revert value for right alpha transformation
			this.transformation.color.alphaMultiplier = value;
			if(value > 0){
				this.transformation.color.type += Color.ALPHA;
			}else if((this.transformation.color.type & Color.ALPHA) != 0){
				this.transformation.color.type -= Color.ALPHA;
			}
		}

		public function set position(value:Vector3D):void {
			this.transformation.matrix.tx = value.x;
			this.transformation.matrix.ty = value.y;
		}

		//end of transformations
		//playback
		public function get currentFrame():int {
			return _currentFrame;
		}

		public function set currentFrame(value:int):void {
			if(!_onPause)_currentFrame = value;
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
			return _onPause;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
