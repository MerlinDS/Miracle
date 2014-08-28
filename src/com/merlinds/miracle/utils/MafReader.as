/**
 * User: MerlinDS
 * Date: 18.07.2014
 * Time: 18:24
 */
package com.merlinds.miracle.utils {
	import com.merlinds.miracle.animations.Animation;

	import flash.utils.ByteArray;

	public class MafReader {

		private var _animations:Vector.<Animation>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MafReader() {
		}

		public function execute(bytes:ByteArray):void {
			_animations = new <Animation>[];
			//ignore signature
			bytes.position = 4;
			var animationList:Array = bytes.readObject();
			var n:int = animationList.length;
			for(var i:int = 0; i < n; i++){

			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get animations():Vector.<Animation> {
			return _animations;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
