/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 18:31
 */
package com.merlinds.miracle.display {

	public class MiracleImage extends MiracleDisplayObject{

		public function MiracleImage(materialName:String) {
			super(materialName);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		override public function draw():void{
			//nothing to do for image
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
