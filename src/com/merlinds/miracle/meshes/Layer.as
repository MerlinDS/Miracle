/**
 * User: MerlinDS
 * Date: 26.08.2014
 * Time: 16:50
 */
package com.merlinds.miracle.meshes {
	/**
	 * Layers of animation.
	 * Contains transformation parameters for the meshes and frames description.
	 */
	public class Layer {

		/** List of the transformations **/
		public var transformations:Vector.<MeshMatrix>;
		/** List of the frames description **/
		public var frames:Vector.<Frame>;
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 */
		public function Layer() {
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
