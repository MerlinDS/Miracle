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

		function drawFrame():void;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function set context(value:Context3D):void;
		//} endregion GETTERS/SETTERS ==================================================
	}
}
