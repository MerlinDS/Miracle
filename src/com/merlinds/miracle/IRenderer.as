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
		function end(present:Boolean = true):void;
		function reload(callback:Function):void;
		function kill():void;

		function drawFrames(time:Number):void;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function set context(value:Context3D):void;
		//} endregion GETTERS/SETTERS ==================================================
	}
}
