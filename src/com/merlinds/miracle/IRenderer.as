/**
 * User: MerlinDS
 * Date: 02.04.2014
 * Time: 20:26
 */
package com.merlinds.miracle {

	import flash.display3D.Context3D;
	import flash.events.IEventDispatcher;

	internal interface IRenderer {
		//==============================================================================
		//{region							METHODS
		function reload(callback:Function):void;
		function pause():void
		function resume():void;
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		function set context(value:Context3D):void;
		function set timer(value:IEventDispatcher):void
		//} endregion GETTERS/SETTERS ==================================================
	}
}
