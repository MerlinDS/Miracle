/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:09
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleImage;

	import flash.geom.Vector3D;

	public interface IScene {
		//==============================================================================
		//{region							METHODS
		/**
		 * Create instance of the image on current scene
		 * @param meshName Name of the mesh that will be used to create
		 * @param textureName Name of the texture that will be used to create
		 * instance of the display object
		 * @param position Position of the display object on scene.
		 * <ul>
		 *    <li> x - x position on scene, range from -1 to 1 </li>
		 *    <li> y - y position on scene, range from -1 to 1 </li>
		 *    <li> z - depth on the scene, range from -1 to 1 </li>
		 * </ul>
		 * @param serializer Prototype of the instance
		 * @return Instance of the display object
		 */
		function createImage(meshName:String, textureName:String, position:Vector3D = null, serializer:Class = null):MiracleImage;
		/**
		 * Create instance of the animation on current scene
		 * @param name Name of the asset that will be used to create
		 * instance of the display object
		 * @param position Position of the display object on scene.
		 * <ul>
		 *    <li> x - x position on scene, range from -1 to 1 </li>
		 *    <li> y - y position on scene, range from -1 to 1 </li>
		 *    <li> z - depth on the scene, range from -1 to 1 </li>
		 * </ul>
		 * @param serializer Prototype of the instance
		 * @return Instance of the display object
		 */
		function createAnimation(name:String, position:Vector3D = null, serializer:Class = null):MiracleAnimation;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
