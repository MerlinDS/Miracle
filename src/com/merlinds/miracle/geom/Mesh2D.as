/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 19:24
 */
package com.merlinds.miracle.geom {
	/**
	 * Instance of this class contains polygons for animated object
	 */
	public dynamic class Mesh2D extends Object{

		/** name of the texture to used for this mesh**/
		public var textureLink:String;

		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param textureLink Name of the texture to used for this mesh
		 */
		public function Mesh2D(textureLink:String = null) {
			this.textureLink = textureLink;
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
