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
		 * @param mesh Name of the mesh
		 * @param animation Name of the animation
		 * @return Instance of the display object
		 */
		function createImage(mesh:String = null, animation:String = null):MiracleImage;
		/**
		 * Create instance of the animation on current scene
		 * @param mesh Name of the mesh
		 * @param animation Name of the animation
		 * @return Instance of the display object
		 */
		function createAnimation(mesh:String, animation:String, fps:int = 60):MiracleAnimation;

		function textureInUse(texture:String):Boolean;

		function createInstance(serializer:Class):MiracleDisplayObject;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function get scale():Number;
		//} endregion GETTERS/SETTERS ==================================================
	}
}
