/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 19:24
 */
package com.merlinds.miracle.geom {
	public dynamic class Mesh2D extends Object{

		public var textureLink:String;
		public var scale:Number = 1;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function Mesh2D(textureLink:String = null, scale:Number = 1) {
			this.textureLink = textureLink;
			this.scale = scale;
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
