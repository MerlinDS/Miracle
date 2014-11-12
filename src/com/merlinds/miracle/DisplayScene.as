/**
 * User: MerlinDS
 * Date: 26.09.2014
 * Time: 18:49
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.textures.TextureHelper;
	import com.merlinds.miracle.utils.Asset;
	import com.merlinds.miracle.utils.delay.delayExecution;

	import flash.geom.Point;

	public class DisplayScene extends RenderScene implements IScene{

		private var _displayObjects:Vector.<MiracleDisplayObject>;
		private var _textureNeedToUpload:Vector.<TextureHelper>;
		private var _errorsQueue:Vector.<Error>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function DisplayScene(assets:Vector.<Asset>, scale:Number = 1) {
			_displayObjects = new <MiracleDisplayObject>[];
			_textureNeedToUpload = new <TextureHelper>[];
			_errorsQueue = new <Error>[];
			super (assets, scale);
		}

		public function createImage(mesh:String = null, animation:String = null, frame:uint = 0):MiracleImage {
			var instance:MiracleImage = this.createInstance(MiracleImage) as MiracleImage;
			instance.mesh = mesh;
			instance.animation = animation;
			instance.currentFrame = frame;
			return instance as MiracleImage;
		}

		public function createAnimation(mesh:String, animation:String, fps:int = 60):MiracleAnimation{
			var instance:MiracleAnimation = this.createInstance(MiracleAnimation) as MiracleAnimation;
			instance.mesh = mesh;
			instance.animation = animation;
			instance.currentFrame = 0;
			instance.fps = fps;
			return instance;
		}

		public function createInstance(serializer:Class):MiracleDisplayObject {
			var instance:MiracleDisplayObject = new serializer();
			_displayObjects[ _displayObjects.length++ ] = instance;
			if(instance.miracle_internal::demandAnimationInstance){
				//create new animation helper and set it to instance
				var animation:AnimationHelper = _animations[  instance.mesh + "." + instance.animation ];
				animation = animation.clone();
				instance.animation = instance.animation + "clone";
				_animations[  instance.mesh + "." + instance.animation ] = animation;
				instance.miracle_internal::animationInstance = animation;
			}
			trace("Miracle: Instance was created.", serializer);
			return instance;
		}

		public function removeInstance(instance:MiracleDisplayObject):void {
			var index:int = _displayObjects.indexOf(instance);
			if(index > - 1){
				//delete instance only on next frame
				delayExecution(_displayObjects.splice, 0, index, 1);
			}
		}

		public function textureInUse(texture:String):Boolean{
			var textureHelper:TextureHelper = _textures[texture];
			return textureHelper.inUse;
		}

		public function hitTest(point:Point):Object {
			// if nothing else is hit, the stage returns itself as target
			var target:MiracleDisplayObject;
			var i:int = _drawableObjects.length;
			while(i-- > 0){
				target = _drawableObjects[i];
				if(target.hitTest(point)){
					break;
				}
				target = null;
			}
			return target == null ? this : target;
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Sort display object in display objects list.
		 * Remove from the list objects that will not be drawn.
		 */
		[Inline]
		private final function prepareDrawObjects():void{
			var instance:MiracleDisplayObject;
			var n:int = _displayObjects.length;
			for(var i:int = 0; i < n; i++){
				instance = _displayObjects[i];
				if( this.readyToDraw(instance) ){
					//add to draw list
					_drawableObjects.push(instance);
				}
			}
		}

		[Inline]
		private final function readyToDraw(instance:MiracleDisplayObject):Boolean {
			var readiness:int = 4;
			var meshHelper:Mesh2D;
			var textureHelper:TextureHelper;
			//check instance for mesh and animation field are filed
			if(instance.mesh != null && instance.animation != null)readiness--;
			if(instance.visible)readiness--;
			//check for animation
			if(_animations.hasOwnProperty( instance.mesh + "." + instance.animation ))
				readiness--;
			//check for necessary objects for instance
			meshHelper =  _meshes[ instance.mesh ];
			textureHelper = _textures[ meshHelper.textureLink ];

			if(meshHelper == null || textureHelper == null){
				_errorsQueue.push(new ArgumentError("Can not draw display object without mesh or texture"));
			}else{
				//check that texture was already uploaded
				if(textureHelper.inUse)readiness--;
				else if(!textureHelper.uploading){
					if(_textureNeedToUpload.indexOf(textureHelper) < 0){
						_textureNeedToUpload.push(textureHelper);
					}
				}
			}
			return readiness == 0;
		}

		[Inline]
		private final function uploadTextures():void {
			//TODO MF-51 Load texture one by one
			var textureHelper:TextureHelper;
			var n:int = _textureNeedToUpload.length;
			while(--n >= 0){
				textureHelper = _textureNeedToUpload[n];
				textureHelper.texture = _context.createTexture(textureHelper.width,
						textureHelper.height, textureHelper.format, false);
			}
			_textureNeedToUpload.length = 0;
		}

		[Inline]
		private final function sortMethod(a:MiracleDisplayObject, b:MiracleDisplayObject):Number {
			if(a.z == b.z)return 0;
			if(a.z < b.z)return 1;
			return -1;//if(a.z > b.z)
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		override public function drawFrame(time:Number):void {
			//clear previous objects list
			_drawableObjects.length = 0;
			//prepare frame data
			this.prepareDrawObjects();
			_drawableObjects.sort(this.sortMethod);
			this.uploadTextures();
			//throw all errors that was collected
			if(_errorsQueue.length > 0)throw _errorsQueue.shift();
			//draw frame
			super.drawFrame(time);
		}
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get displayObjects():Vector.<MiracleDisplayObject> {
			return _displayObjects;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
