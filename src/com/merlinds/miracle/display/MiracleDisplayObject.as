/**
 * User: MerlinDS
 * Date: 03.04.2014
 * Time: 20:56
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.miracle_internal;
	import com.merlinds.miracle.utils.DrawingMatrix;

	import flash.errors.IllegalOperationError;

	public class MiracleDisplayObject {

		miracle_internal var drawMatrix:DrawingMatrix;

		public var materialName:String;

		public function MiracleDisplayObject(materialName:String, drawMatrix:DrawingMatrix = null) {
			this.materialName = materialName;
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}
