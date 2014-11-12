/**
 * User: MerlinDS
 * Date: 12.11.2014
 * Time: 14:03
 */
package com.merlinds.miracle.utils.delay {
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	internal class DelayManager {

		private static var _instance:DelayManager;

		private var _onNextFrame:Vector.<DelayMethod>;
		private var _methods:Vector.<DelayMethod>;

		private var _intervalId:uint;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function DelayManager(singletonKey:SingletoneKey){
			if(singletonKey == null){
				throw new ArgumentError("This is a singleton. Use getInstance instead.");
			}
			_methods = new <DelayMethod>[];
			_onNextFrame = new <DelayMethod>[];
		}

		public static function getInstance():DelayManager {
			if(_instance == null){
				_instance = new DelayManager( new SingletoneKey() );
			}

			return _instance;
		}

		public function add(delayMethod:DelayMethod):void{
			_methods[_methods.length] = delayMethod;
			if(_intervalId == 0)_intervalId = setTimeout(this.tickHandler, 0);
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		private function tickHandler():void {
			//release from timer
			clearTimeout(_intervalId);
			_intervalId = 0;
			//execute delay methods
			var frameTime:int = getTimer();
			while (_methods.length) {
				var delayMethod:DelayMethod = _methods.pop();
				if (delayMethod.delay == 0) {
					delayMethod.execute();
				} else {
					_onNextFrame[_onNextFrame.length] = delayMethod;
					delayMethod.delay--;
				}
				//===============================
				if (getTimer() - frameTime > 16) {
					break;
				}
			}
			_methods = _methods.concat(_onNextFrame);
			_onNextFrame.length = 0;
			if(_methods.length > 0){
				//add new timeout if not all methods was executed
				_intervalId = setTimeout(this.tickHandler, 0);
			}

		}
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
class SingletoneKey{}
