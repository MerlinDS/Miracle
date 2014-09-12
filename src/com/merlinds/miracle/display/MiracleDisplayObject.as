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

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
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
		/**
		 * Name of the texture that will be used
		 */
		public var texture:String;
		/**
		 * Position of the display object on scene.
		 * <ul>
		 *    <li> x - x position on scene, range from -1 to 1 </li>
		 *    <li> y - y position on scene, range from -1 to 1 </li>
		 *    <li> z - depth on the scene, range from -1 to 1 </li>
		 * </ul>
		 */
		private var _position:Vector3D;
		private var _currentFrame:int;

		public var transformation:Transformation;

		private var _width:int;
		private var _height:int;

		private var _fps:int;

		private var _onStage:Boolean;
		private var _onPause:Boolean;

		public function MiracleDisplayObject(mesh:String = null, texture:String = null) {
			this.transformation = new Transformation( new TransformMatrix(), new Color(), new Rectangle());
			this.mesh = mesh;
			this.texture = texture;
			this.fps = 60;//Default frame rate
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function stop():void {
			_onPause = true;
		}

		public function play():void {
			_onPause = false;
		}

		public function moveTO(x:Number = 0, y:Number = 0, z:Number = 0):MiracleDisplayObject {
			if(_position == null){
				_position = new Vector3D(x, y, z);
			}
			_position.x = this.transformation.matrix.tx = x;
			_position.y = this.transformation.matrix.ty = y;
			return this;
		}
		/**
		 * must be overridden
		 */
		public function draw():void{
			throw new IllegalOperationError("This method must be overridden!");
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

		public function get position():Vector3D {
			return _position;
		}

		public function set position(value:Vector3D):void {
			this.transformation.matrix.tx = value.x;
			this.transformation.matrix.ty = value.y;
			_position = value;
		}

		public function get width():int {
			return _width;
		}

		public function set width(value:int):void {
			_width = value;
		}

		public function get height():int {
			return _height;
		}

		public function set height(value:int):void {
			_height = value;
		}

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

		public function get animation():String {
			return _animation;
		}

		public function set animation(value:String):void {
			_animation = value;
			_currentFrame = 0;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
