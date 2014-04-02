/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 17:59
 */
package com.merlinds.miracle {;

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	public final class Miracle {

		private static var _instance:MiracleInstance;
		private static var _scenesList:Vector.<IScene>;
		private static var _currenScene:int;
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
			if (_instance == null) {
				//prepare native stage
				nativeStage.frameRate = 60;
				nativeStage.align = StageAlign.TOP_LEFT;
				nativeStage.scaleMode = StageScaleMode.NO_SCALE;
				//create _instance
				var localInstance:MiracleInstance = new MiracleInstance(nativeStage);
				localInstance.addEventListener(Event.COMPLETE, function(event:Event):void{
					localInstance.removeEventListener(event.type, arguments.callee);
					trace("Miracle: Start completed");
					_instance = localInstance;
					_scenesList = new <IScene>[];
					_currenScene = -1;
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

		public static function createScene():IScene {
			if(_instance == null){
				throw new IllegalOperationError("Miracle was not started. Use start() ");
			}
			var index:int = _scenesList.length;
			_scenesList[index] = new Scene();
			//if scenes is empty, add scene to instance
			if(_currenScene < 0){
				_currenScene = 0;
				_instance.scene = _scenesList[ _currenScene ] as IRenderer;
			}
			trace("Miracle: new scene was added. Index:", index);
			return _scenesList[index];
		}

		public static function switchScene(index:int, callback:Function = null):Boolean {
			if(_instance == null){
				throw new IllegalOperationError("Miracle was not started. Use start() ");
			}
			var result:Boolean = true;
			if(_currenScene < 0){
				//create new scene
				createScene();
			}else
			{
				if(index >= _scenesList.length){
					result = false;
					trace("Miracle: Cannot switch scene to index", index);
				}else{
					_instance.scene = _scenesList[ _currenScene ] as IRenderer;
					trace("Miracle: Switch scene to index ", index);
				}
			}
			//TODO: Execute callback by screen, when it will be switched
			if(result && callback is Function){
				callback.apply(null);
			}
			return result;
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
			return _instance != null;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}


