/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:09
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.display.MiracleImage;

	public interface IScene {
		//==============================================================================
		//{region							METHODS
		/**
		 * Create instance of the image on current scene
		 * @param serializer Prototype of the instance
		 * @return Instance of the display object
		 */
		function createImage(texture:String = null, anim:String = null):MiracleImage;
		/**
		 * Create instance of the animation on current scene
		 * @param serializer Prototype of the instance
		 * @return Instance of the display object
		 */
		function createAnimation():MiracleAnimation;

		function textureInUse(texture:String):Boolean;

		function createInstance(serializer:Class):MiracleDisplayObject;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function get scale():Number;
		//} endregion GETTERS/SETTERS ==================================================
	}
}
