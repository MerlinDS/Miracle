/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 20:56
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.meshes.Mesh2D;
	import com.merlinds.miracle.meshes.Mesh2DCollection;
	import com.merlinds.miracle.miracle_internal;
	import com.merlinds.miracle.utils.DrawingMatrix;

	import flash.errors.IllegalOperationError;

	public class MiracleDisplayObject {

		miracle_internal var drawMatrix:DrawingMatrix;
		miracle_internal var currentMesh:Mesh2D;

		public var meshCollection:Mesh2DCollection;

		public function MiracleDisplayObject(meshCollection:Mesh2DCollection,
		                                     drawMatrix:DrawingMatrix = null) {
			this.meshCollection = meshCollection;
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
		public function get name():String{
			return this.meshCollection.name;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
