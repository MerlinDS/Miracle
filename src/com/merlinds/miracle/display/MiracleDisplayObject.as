/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 20:56
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.miracle_internal;
	import com.merlinds.miracle.utils.DrawingMatrix;

	import flash.errors.IllegalOperationError;
	import flash.geom.Vector3D;

	public class MiracleDisplayObject {

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
		/**
		 * must be overridden
		 */
		public function draw():void{
			throw new IllegalOperationError("This method must be overridden!");
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

		public function get position():flash.geom.Vector3D {
			return _position;
		}

		public function set position(value:Vector3D):void {
			drawMatrix.tx = value.x * 1000;
			drawMatrix.ty = value.y * 1000;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
