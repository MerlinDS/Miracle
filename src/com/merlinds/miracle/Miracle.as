/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 17:59
 */
package com.merlinds.miracle {

	import com.merlinds.miracle.utils.Asset;

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.setTimeout;

	public final class Miracle {

		private static var _instance:MiracleInstance;
		private static var _scene:IScene;
		//
		private static var _reloadCallback:Function;
		private static var _lostContextCallback:Function;
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
				var instance:MiracleInstance = new MiracleInstance(nativeStage);
				instance.addEventListener(Event.COMPLETE, function(event:Event):void{
					instance.removeEventListener(event.type, arguments.callee);
					instance.addEventListener(Event.COMPLETE, Miracle.completeHandler);
					instance.addEventListener(Event.CLOSE, Miracle.lostContextHandler);
					trace("Miracle: Start completed");
					_instance = instance;
					if(callback is Function){
						callback.apply(null);
					}
				});
				setTimeout(instance.start, 0, enableErrorChecking);
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
			scene.create(assets, function():void{
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
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private static function lostContextHandler(event:Event):void {
			trace("Miracle: Context was lost. Try to reload Miracle");
			if(_lostContextCallback is Function){
				_lostContextCallback.apply();
			}
		}

		private static function completeHandler(event:Event):void {
			trace("Miracle: Context was reloaded successful");
			if(_reloadCallback is Function){
				_reloadCallback.apply();
			}
		}
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

		public static function set reloadCallback(value:Function):void {
			_reloadCallback  = value;
		}

		public static function set lostContextCallback(value:Function):void {
			_lostContextCallback = value;
		}
//} endregion GETTERS/SETTERS ==================================================
	}
}


