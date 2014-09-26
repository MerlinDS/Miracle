/**
 * User: MerlinDS
 * Date: 26.09.2014
 * Time: 18:49
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.textures.TextureHelper;
	import com.merlinds.miracle.utils.Asset;

	import flash.geom.Point;

	import flash.utils.setTimeout;

	public class DisplayScene extends RenderScene implements IScene{

		//==============================================================================
		//{region							PUBLIC METHODS
		public function DisplayScene(assets:Vector.<Asset>, scale:Number = 1) {
			super (assets, scale);
		}

		public function createImage(mesh:String = null, animation:String = null):MiracleImage {
			var instance:MiracleDisplayObject = this.createInstance(MiracleImage);
			instance.mesh = mesh;
			instance.animation = animation;
			instance.currentFrame = 0;
			return instance as MiracleImage;
		}

		public function createAnimation(mesh:String, animation:String, fps:int = 60):MiracleAnimation{
			var instance:MiracleDisplayObject = this.createInstance(MiracleAnimation);
			instance.mesh = mesh;
			instance.animation = animation;
			instance.currentFrame = 0;
			instance.fps = fps;
			return instance as MiracleAnimation;
		}

		public function createInstance(serializer:Class):MiracleDisplayObject {
			var instance:MiracleDisplayObject = new serializer();
			_displayObjects[_displayObjects.length++] = instance;
			trace("Miracle: Instance was created.");
			return instance;
		}

		public function removeInstance(instance:MiracleDisplayObject):void {
			var index:int = _displayObjects.indexOf(instance);
			if(index > - 1){
				//delete instance only on next frame
				setTimeout(_displayObjects.splice, 0, index, 1);
			}
		}

		public function textureInUse(texture:String):Boolean{
			var textureHelper:TextureHelper = _textures[texture];
			return textureHelper.inUse;
		}

		public function hitTest(point:Point):Object {
			// if nothing else is hit, the stage returns itself as target
			var target:MiracleDisplayObject;
			var n:int = _displayObjects.length;
			for(var i:int = 0; i < n; i++){
				target = _displayObjects[i];
				if(target.hitTest(point)){
					break;
				}
				target = null;
			}
//			= super.hitTest(localPoint, forTouch);
			return target == null ? this : target;
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
		public function get displayObjects():Vector.<MiracleDisplayObject> {
			return _displayObjects;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
