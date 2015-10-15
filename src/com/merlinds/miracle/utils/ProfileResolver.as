package com.merlinds.miracle.utils
{

	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.setTimeout;

	/**
	 * Resolve profile for mobile
	 */
	public class ProfileResolver
	{
		public static const STANDARD_EXTENDED:String = "standardExtended";
		public static const STANDARD:String = "standard";
		public static const STANDARD_CONSTRAINED:String = "standardConstrained";
		public static const BASELINE_EXTENDED:String = "baselineExtended";
		public static const BASELINE:String = "baseline";
		public static const BASELINE_CONSTRAINED:String = "baselineConstrained";

		private var _stage3D:Stage3D;
		private var _availableProfiles:Vector.<String>;
		private var _currentProfile:String;
		private var _renderMode:String;

		private var _onContextCreated:Function;
//======================================================================================================================
//{region											PUBLIC METHODS
		public function ProfileResolver(stage3D:Stage3D, onContextCreated:Function)
		{
			_stage3D = stage3D;
			_onContextCreated = onContextCreated;
		}

		public function requestContext3D(renderMode:String = "auto"):void
		{
			_renderMode = renderMode;
			this.initialize();
			this.requestNextProfile();
//			_stage3D.requestContext3D(renderMode, Context3DProfile.BASELINE_CONSTRAINED);
		}

		public function addAvailableProfile(profile:String):void
		{
			if(_availableProfiles == null)
				_availableProfiles = new <String>[];
			_availableProfiles[_availableProfiles.length] = profile;
		}
//} endregion PUBLIC METHODS ===========================================================================================
//======================================================================================================================
//{region										PRIVATE\PROTECTED METHODS
		[Inline]
		private final function initialize():void
		{
			if(_availableProfiles == null || _availableProfiles.length == 0)
			{
				_availableProfiles = new <String>[STANDARD_EXTENDED, STANDARD, STANDARD_CONSTRAINED,
					BASELINE_EXTENDED, BASELINE, BASELINE_CONSTRAINED];
			}
			_stage3D.addEventListener(ErrorEvent.ERROR, this.errorHandler, false, 100);
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, this.contextCreatedHandler, false, 100);
		}

		[Inline]
		private final function dispose():void
		{
			_stage3D.removeEventListener(ErrorEvent.ERROR, this.errorHandler);
			_stage3D.removeEventListener(Event.CONTEXT3D_CREATE, this.contextCreatedHandler);
			_availableProfiles = null;
			_onContextCreated = null;
			_currentProfile = null;
			_renderMode = null;
			_stage3D = null;
		}

		private final function requestNextProfile():void
		{
			_currentProfile = _availableProfiles.shift();
			try {
				_stage3D.requestContext3D(_renderMode, _currentProfile);
			}
			catch (error:Error)
			{
				if (_availableProfiles.length != 0)
					setTimeout( this.requestNextProfile, 1);
				else throw error;
			}
		}

		private function errorHandler(event:Event):void
		{
			if(_availableProfiles.length > 0)
			{
				event.stopImmediatePropagation();
				setTimeout( this.requestNextProfile, 1);
			}
			else
				this.dispose();

		}

		private function contextCreatedHandler(event:Event):void
		{
			var context:Context3D = _stage3D.context3D;
			if (_renderMode == Context3DRenderMode.AUTO && _availableProfiles.length != 0 &&
					context.driverInfo.indexOf("Software") != -1)
			{
				this.errorHandler(event);
			}
			else
			{
				_onContextCreated(context);
				this.dispose();
			}
		}
//} endregion PRIVATE\PROTECTED METHODS ================================================================================
//======================================================================================================================
//{region											GETTERS/SETTERS

//} endregion GETTERS/SETTERS ==========================================================================================
	}
}
