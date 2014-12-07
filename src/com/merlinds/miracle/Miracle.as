/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 17:59
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.utils.Asset;

	import flash.display.BitmapData;

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	public final class Miracle {

		private static var _instance:MiracleInstance;
		private static var _scene:IScene;
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
//				nativeStage.frameRate = 60;
				nativeStage.align = StageAlign.TOP_LEFT;
				nativeStage.scaleMode = StageScaleMode.NO_SCALE;
				//create _instance
				var localInstance:MiracleInstance = new MiracleInstance(nativeStage);
				localInstance.addEventListener(Event.COMPLETE, function(event:Event):void{
					localInstance.removeEventListener(event.type, arguments.callee);
					trace("Miracle: Start completed");
					_instance = localInstance;
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

		/**
		 *
		 * @param assets Assets for this scene
		 * @param callback Initialization scene complete
		 * @param scale Global scale of the scene
		 * @return New Scene
		 */
		public static function createScene(assets:Vector.<Asset>, callback:Function, scale:Number = 1):void {
			if(_instance == null){
				throw new IllegalOperationError("Miracle was not started. Use start() before creating scene ");
			}
			var scene:AbstractScene = new DisplayScene(scale);
			_scene = scene as IScene;
			_instance.scene = scene as IRenderer;
			scene.initialize(assets, function():void{
				trace("Miracle: new scene was initialized. ");
				_instance.resume();
				callback.apply(this);
			});
		}

		public static function pause():Boolean {
			if(_instance != null){
				_instance.pause();
				return true;
			}
			return false;
		}

		public static function resume():Boolean {
			if(_instance != null){
				_instance.resume();
				return _instance.reloading;
			}
			return false;
		}

		public static function reload(callback:Function = null):void{
			if(_instance != null){
				_instance.addEventListener(Event.COMPLETE, function(event:Event):void{
					_instance.removeEventListener(event.type, arguments.callee);
					trace("Miracle: Reload completed");
					callback.apply(this);
					callback = null;
				});
				_instance.reload();
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
		public static function get isStarted():Boolean{
			return _instance != null;
		}

		public static function get scene():IScene {
			return  _scene;
		}
//} endregion GETTERS/SETTERS ==================================================
	}
}


