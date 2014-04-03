/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:26
 */
package com.merlinds.miracle {
	import flash.display3D.Context3D;

	internal interface IRenderer {
		//==============================================================================
		//{region							METHODS
		function start():void;
		function end():void;
		function kill():void;

		function setTexture(texture:Mesh2DCollection):void;

		function draw(shape:Mesh2D, tx:Number, ty:Number,
		              scaleX:Number, scaleY:Number, skewX:Number, skewY:Number):void;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function set context(value:Context3D):void;
		//} endregion GETTERS/SETTERS ==================================================
	}
}
