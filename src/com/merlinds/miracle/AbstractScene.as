/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:42
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.utils.Asset;

	import flash.display3D.Context3D;

	internal class AbstractScene implements IRenderer{

		protected var _context:Context3D;
		//maps
		protected var _materials:Object;/**Materials**/
		protected var _displayObjects:Vector.<MiracleDisplayObject>;

		public function AbstractScene(assets:Vector.<Asset>) {
			_materials = {};
			_displayObjects = new <MiracleDisplayObject>[];
			this.initialize(assets);
		}

		//==============================================================================
		//{region							PUBLIC METHODS

		public function start():void {
		}

		public function end():void {
		}

		public function kill():void {
		}

		public function drawFrame():void {
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		[Inline]
		protected function initialize(assets:Vector.<Asset>):void{

		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function set context(value:Context3D):void {
			_context = value;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
