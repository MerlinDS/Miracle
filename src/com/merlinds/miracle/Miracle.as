/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 17:59
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleSceen;

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	public final class Miracle {

		private static var instance:MiracleInstance;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function Miracle() {
			throw new IllegalOperationError("Miracle cannot be instantiated!");
		}

		/**
		 * Start Miracle
		 * @param nativeStage Native flash stage
		 * @param callback Callback method that will be executed after Miracle activated
		 * @param enableErrorChecking Specifies whether errors encountered
		 * by the renderer are reported to the application.
		 *
		 * @throws flash.errors.IllegalOperationError if Miracle was started
		 */
		public static function start(nativeStage:Stage, callback:Function = null,
		                             enableErrorChecking:Boolean = true):void {
			if (instance == null) {
				//prepare native stage
				nativeStage.frameRate = 60;
				nativeStage.align = StageAlign.TOP_LEFT;
				nativeStage.scaleMode = StageScaleMode.NO_SCALE;
				//create instance
				var localInstance:MiracleInstance = new MiracleInstance(nativeStage);
				localInstance.addEventListener(Event.COMPLETE, function(event:Event):void{
					localInstance.removeEventListener(event.type, arguments.callee);
					trace("Miracle: Start completed");
					instance = localInstance;
					if(callback is Function){
						callback.apply(null);
					}
				});
				localInstance.start(enableErrorChecking);
			} else {
				throw new IllegalOperationError("Miracle already happened! " +
					"Only one miracle per game session could be started.");
			}
		}

		public static function getScreen(index:int):MiracleSceen {
			return null;
		}

		public static function switchSceen(index:int, callback:Function):Boolean {
			return false;
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
		public static function get isStarted():Boolean{
			return instance != null;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}


