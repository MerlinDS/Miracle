/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:09
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleImage;

	public interface IScene {
		//==============================================================================
		//{region							METHODS
		/**
		 * Create instance of the image on current scene
		 * @param serializer Prototype of the instance
		 * @return Instance of the display object
		 */
		function createImage(serializer:Class = null):MiracleImage;
		/**
		 * Create instance of the animation on current scene
		 * @param serializer Prototype of the instance
		 * @return Instance of the display object
		 */
		function createAnimation(serializer:Class = null):MiracleAnimation;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
