/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:26
 */
package com.merlinds.miracle {

	import flash.display.Stage;
	import flash.display3D.Context3D;

	internal interface IRenderer {
		//==============================================================================
		//{region							METHODS
		function initialize(context:Context3D, timer:Stage, lostContextCallback:Function):void;
		function restore(callback:Function):void;
		function stopRestoring():void;
		function pause():void
		function resume():void;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function set debugOn(value:Boolean):void;
		//} endregion GETTERS/SETTERS ==================================================
	}
}
