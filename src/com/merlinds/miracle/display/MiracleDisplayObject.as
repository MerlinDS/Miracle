/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 20:56
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.events.MiracleEvent;
	import com.merlinds.miracle.miracle_internal;
	import com.merlinds.miracle.utils.DrawingMatrix;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;

	[Event(type="com.merlinds.miracle.events.MiracleEvent", name="addedToStage")]
	public class MiracleDisplayObject extends EventDispatcher{

		use namespace miracle_internal;

		miracle_internal var drawMatrix:DrawingMatrix;

		/**
		 * Name of the mesh that will be used
		 */
		public var mesh:String;
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

		private var _width:int;
		private var _height:int;

		private var _onStage:Boolean;

		public function MiracleDisplayObject(mesh:String = null, texture:String = null,
		                                     drawMatrix:DrawingMatrix = null) {
			this.mesh = mesh;
			this.texture = texture;
			if(drawMatrix == null){
				this.miracle_internal::drawMatrix = new DrawingMatrix();
			}
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		public function moveTO(x:Number = 0, y:Number = 0, z:Number = 0):MiracleDisplayObject {
			if(_position == null){
				_position = new Vector3D(x, y, z);
			}
			_position.x = drawMatrix.tx = x;
			_position.y = drawMatrix.ty = y;
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
			drawMatrix.tx = value.x;
			drawMatrix.ty = value.y;
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

//} endregion GETTERS/SETTERS ==================================================
	}
}
