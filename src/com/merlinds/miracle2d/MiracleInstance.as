/**
 * Created by MerlinDS on 27.03.2015.
 */
package com.merlinds.miracle2d
{

	import flash.display.Stage;
	import flash.errors.IllegalOperationError;

	//TODO: Add Miracle notification
	/**
	 * Miracle2D instance class. Can be created only by com.merlinds.miracle2d.Miracle2D
	 */
	internal class MiracleInstance
	{

		use namespace miracle2d_namespace;
		//user configuration
		private var _nativeStage:Stage;
		private var _enableErrorChecking:Boolean;
		private var _useExternalTimer:Boolean;

		//Miracle2D dependencies
		private var _currentScene:Miracle2DSceneInstance;
		private var _systemManager:Miracle2DSystemManager;
		//Miracle2D ancillary parameters
		//Time parameters
		private var _passedTime:Number;
		private var _lastFrameTimestamp:Number;
//======================================================================================================================
//{region											PUBLIC METHODS
		public function MiracleInstance()
		{
			_systemManager = new Miracle2DSystemManager();
		}

		/**
		 * Install Miracle2D to use in application. Create dependencies and initial scene.
		 * @param stage Native application stage.
		 * @param enableErrorChecking
		 * @param useExternalTimer
		 */
		public function install(stage:Stage, enableErrorChecking:Boolean = true, useExternalTimer:Boolean = false):void
		{
			if(_nativeStage != null)
			{
				throw new IllegalOperationError("Miracle2D can not be installed twice");
			}
			//save configuration
			_nativeStage = stage;
			_enableErrorChecking = enableErrorChecking;
			_useExternalTimer = useExternalTimer;//May be move this to scene
			//initialize Miracle2D and create dependencies
			//create initial scene
			_currentScene = new Miracle2DSceneInstance();
			_systemManager.init(_nativeStage);
		}

		/**
		 * External tick handler
		 */
		public function tick():void
		{
			var now:Number = new Date().time;
			_passedTime = now - _lastFrameTimestamp;
			_lastFrameTimestamp = now;
			_systemManager.tick(_passedTime);
		}
//} endregion PUBLIC METHODS ===========================================================================================
//======================================================================================================================
//{region										PRIVATE\PROTECTED METHODS

//} endregion PRIVATE\PROTECTED METHODS ================================================================================
//======================================================================================================================
//{region											GETTERS/SETTERS
		/**
		 * Return current scene of Miracle2D.
		 */
		public function get currentScene():Miracle2DSceneInstance
		{
			return _currentScene;
		}

//} endregion GETTERS/SETTERS ==========================================================================================
	}
}
