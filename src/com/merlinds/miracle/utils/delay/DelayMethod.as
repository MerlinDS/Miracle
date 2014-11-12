/**
 * User: MerlinDS
 * Date: 12.11.2014
 * Time: 13:55
 */
package com.merlinds.miracle.utils.delay {
	internal class DelayMethod {

		private var _method:Function;
		private var _arguments:Array;
		private var _delay:int;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function DelayMethod(method:Function, delay:int, args:Array) {
			_method = method;
			_delay = delay;
			_arguments = args;
		}

		public function execute():void {
			_method.apply(this, _arguments);
			this.detroy();
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function detroy():void{
			_method = null;
			_arguments = null;
			_delay = 0;
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS

		public function get delay():int {
			return _delay;
		}

		public function set delay(value:int):void {
			_delay = value;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
