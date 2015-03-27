/**
 * Created by MerlinDS on 27.03.2015.
 */
package com.merlinds.miracle2d
{

	import com.merlinds.miracle2d.system.AssetsSystem;
	import com.merlinds.miracle2d.system.InstancesSystem;
	import com.merlinds.miracle2d.system.Miracle2DSystem;
	import com.merlinds.miracle2d.system.PostEffectSystem;
	import com.merlinds.miracle2d.system.RenderSystem;
	import com.merlinds.miracle2d.system.ShaderSystem;
	import com.merlinds.miracle2d.system.StageSystem;

	import flash.display.Stage;

	internal class Miracle2DSystemManager
	{
		use namespace miracle2d_namespace;

		private var _systems:Vector.<Miracle2DSystem>;
		private var _systemsCount:int;
		//======================================================================================================================
//{region											PUBLIC METHODS
		public function Miracle2DSystemManager()
		{
		}

		public function init(nativeStage:Stage):void
		{
			_systems = new <Miracle2DSystem>[
				new AssetsSystem(),
				new StageSystem(),
				new ShaderSystem(),
				new InstancesSystem(),
				new RenderSystem(),
				new PostEffectSystem()
			];
			_systemsCount = _systems.length;
		}

		public function addSystemToScope(systemType:Class):void
		{
			var system:Miracle2DSystem = this.getSystemByType(systemType);
			if(system == null)
				throw new ArgumentError("Can not add unknown system to scope");
			system.inScope = true;
			//TODO: add parameters to system and init it
		}

		public function removeSystemFromScope(systemType:Class):void
		{

			var system:Miracle2DSystem = this.getSystemByType(systemType);
			if(system == null)
				throw new ArgumentError("Can not remove unknown system from scope");
			system.inScope = false;
			//TODO: remove parameters from system and clear it
		}

		public function tick(time:Number):void
		{
			for(var i:int = 0; i < _systemsCount; ++i)
			{
				var system:Miracle2DSystem = _systems[i];
				if(!system.inScope)continue;
				system.update();
			}
		}

//} endregion PUBLIC METHODS ===========================================================================================
//======================================================================================================================
//{region										PRIVATE\PROTECTED METHODS
		[Inline]
		private final function getSystemByType(systemType:Class):Miracle2DSystem
		{
			for(var i:int = 0; i < _systemsCount; ++i)
			{
				if(_systems[i]["constructor"] == systemType)
				{
					return _systems[i];
				}
			}
			return null;
		}
//} endregion PRIVATE\PROTECTED METHODS ================================================================================
//======================================================================================================================
//{region											GETTERS/SETTERS

//} endregion GETTERS/SETTERS ==========================================================================================
	}
}
