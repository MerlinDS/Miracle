/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:36
 */
package com.merlinds.miracle {
	import flash.display3D.Context3D;

	public class MiracleRenderer {

		private var _context:Context3D;

		public function MiracleRenderer() {
		}

		internal function updateContext(context:Context3D):void{
				_context = context;
		}
		//==============================================================================
		//{region							PUBLIC METHODS
		public function start():void {
			_context.clear(0.8, 0.8, 0.8, 1);
		}

		public function end():void{
			this.drawTriangles();
			_context.present();
		}

		public function kill():void {
			_context = null;
		}

		public function setTexture(texture:MiracleTexture):void{

		}

		public function draw(shape:MiracleShape, tx:Number, ty:Number,
		                     scaleX:Number, scaleY:Number, skewX:Number, skewY:Number):void{

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		[Inline]
		private function drawTriangles():void {

		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
