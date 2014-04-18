/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:09
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.materials.Material;
	import com.merlinds.miracle.utils.Asset;

	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public interface IScene {
		//==============================================================================
		//{region							METHODS
		/**
		 * Create Material for this scene
		 * @param name Material name. This name will be used as link inside the Miracle
		 * @param textureData ATF or Bitmap bytes that will be used as texture of this material
		 * @param meshData Special formatted object that describes meshes structure
		 */
		function createMaterial(name:String, textureData:ByteArray, meshData:Array = null):Material;
		/**
		 * Create instance of the image on current scene
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
		function createImage(name:String, position:Vector3D = null, serializer:Class = null):MiracleImage;
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
