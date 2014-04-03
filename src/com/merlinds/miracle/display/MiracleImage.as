/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 18:31
 */
package com.merlinds.miracle.display {
	import com.merlinds.miracle.meshes.Mesh2DCollection;
	import com.merlinds.miracle.miracle_internal;


	public class MiracleImage extends MiracleDisplayObject{

		use namespace miracle_internal;

		public function MiracleImage(meshCollection:Mesh2DCollection) {
			super(meshCollection);
			//initialize first frame as image
			this.currentMesh = this.meshCollection.meshList[0];
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
