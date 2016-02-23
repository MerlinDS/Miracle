/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:09
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.fonts.MiracleText;
	import com.merlinds.miracle.display.MiracleImage;

	import flash.display.BitmapData;

	import flash.geom.Point;

	public interface IScene {
		//==============================================================================
		//{region							METHODS
		/**
		 * Create instance of the image on current scene
		 * @param mesh Name of the mesh
		 * @param animation Name of the animation
		 * @param frame What frame of animation will be display as image
		 * @return Instance of the display object
		 */
		function createImage(mesh:String = null, animation:String = null, frame:uint = 0):MiracleImage;
		/**
		 * Create instance of the animation on current scene
		 * @param mesh Name of the mesh
		 * @param animation Name of the animation
		 * @param fps Speed of the animation
		 * @return Instance of the display object
		 */
		function createAnimation(mesh:String, animation:String, fps:int = 60):MiracleAnimation;

		function createTxt(mesh:String, fontName:String, text:String = null):MiracleText;

		function textureInUse(texture:String):Boolean;

		function createInstance(serializer:Class):MiracleDisplayObject;

		function removeInstance(instance:MiracleDisplayObject):void;

		function hitTest(point:Point):Object;

		function loadTexturesImmediately(textures:Vector.<String> = null, callback:Function = null):void;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function get scale():Number;

		function get displayObjects():Vector.<MiracleDisplayObject>;

		function getScreenShot(width:int, height:int, callback:Function):void;
		//} endregion GETTERS/SETTERS ==================================================
	}
}
