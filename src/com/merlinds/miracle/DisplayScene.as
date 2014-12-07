/**
 * User: MerlinDS
 * Date: 26.09.2014
 * Time: 18:49
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.display.MiracleFont;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.textures.TextureHelper;

	import flash.geom.Point;
	import flash.utils.setTimeout;

	public class DisplayScene extends RenderScene implements IScene{

		private var _displayObjects:Vector.<MiracleDisplayObject>;
		private var _textureNeedToUpload:Vector.<TextureHelper>;
		private var _errorsQueue:Vector.<Error>;
		//loading
		private var _textureLoading:Boolean;
		private var _loadingCallback:Function;
		private var _loadingCallbackSet:Boolean;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function DisplayScene(scale:Number = 1) {
			_displayObjects = new <MiracleDisplayObject>[];
			_textureNeedToUpload = new <TextureHelper>[];
			_errorsQueue = new <Error>[];
			super (scale);
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

		public function createTxt(mesh:String, fontName:String, text:String = null, glyphSize:int = 30):MiracleFont {
			var instance:MiracleFont = this.createInstance(MiracleFont) as MiracleFont;
			instance.mesh = mesh;
			instance.animation = fontName;
			instance.glyphSize = glyphSize;
			instance.currentFrame = 0;
			instance.text = text;
			//
			var animation:AnimationHelper = _animations[  mesh + "." + fontName ];
			animation = animation.clone();
			instance.animation = instance.animation + ".font";
			_animations[  mesh + "." + instance.animation ] = animation;
			instance.miracle_internal::animationInstance = animation;
			//
			return instance;
		}

		public function createInstance(serializer:Class):MiracleDisplayObject {
			var instance:MiracleDisplayObject = new serializer();
			_displayObjects[ _displayObjects.length++ ] = instance;
			if(instance.miracle_internal::demandAnimationInstance){
				//create new animation helper and set it to instance
				var animation:AnimationHelper = _animations[  instance.mesh + "." + instance.animation ];
				animation = animation.clone();
				instance.animation = instance.animation + ".clone";
				_animations[  instance.mesh + "." + instance.animation ] = animation;
				instance.miracle_internal::animationInstance = animation;
			}
			trace("Miracle: Instance was created.", serializer);
			return instance;
		}

		public function removeInstance(instance:MiracleDisplayObject):void {
			var index:int = _displayObjects.indexOf(instance);
			if(index > - 1){
				_displayObjects.splice(index, 1);
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


		public function loadTexturesImmediately(textures:Vector.<String> = null, callback:Function = null):void {
			_loadingCallback = callback;
			_loadingCallbackSet = true;
			//load all textures in textures parameter is null
			var textureHelper:TextureHelper;
			if(textures == null){
				for each(textureHelper in _textures){
					if(!textureHelper.uploading && _textureNeedToUpload.indexOf(textureHelper) < 0){
						_textureNeedToUpload.push(textureHelper);
						textureHelper.uploading = true;
					}
				}
			}else{
				for(var i:int = 0; i < textures.length; i++){
					var name:String = textures[i];
					if(_textures.hasOwnProperty(name)){
						textureHelper = _textures[name];
						if(!textureHelper.uploading && _textureNeedToUpload.indexOf(textureHelper) < 0){
							_textureNeedToUpload.push(textureHelper);
							textureHelper.uploading = true;
						}
					}
				}
			}
		}


		override public function reload(callback:Function):void {
			_drawableObjects.length = 0;
			for each(var textureHelper:TextureHelper in _textures){
				if(textureHelper.inUse){
					//reload texture
					_textureNeedToUpload.push(textureHelper);
					textureHelper.uploading = true;
				}
			}
			_loadingCallbackSet = true;
			_loadingCallback = callback;
			this.uploadTextures();
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
			if(_animations[ instance.animationId] != null)
				readiness--;
			//check for necessary objects for instance
			meshHelper =  _meshes[ instance.mesh ];

			if(meshHelper == null){
				_errorsQueue.push(new ArgumentError("Can not draw display object without mesh"));
			}else{
				textureHelper = _textures[ meshHelper.textureLink ];
				if(textureHelper == null){
					_errorsQueue.push(new ArgumentError("Can not draw display object without texture"));
				}
				//check that texture was already uploaded
				if(textureHelper.inUse)readiness--;
				else if(!textureHelper.uploading){
					if(_textureNeedToUpload.indexOf(textureHelper) < 0){
						_textureNeedToUpload.push(textureHelper);
						textureHelper.uploading = true;
					}
				}
			}
			return readiness == 0;
		}

		[Inline]
		private final function uploadTextures():void {
			if(_textureLoading)return;
			if(_textureNeedToUpload.length > 0){
				_textureLoading = true;
				var textureHelper:TextureHelper = _textureNeedToUpload.pop();
				textureHelper.callback = this.textureCallback;
				textureHelper.texture = _context.createTexture(textureHelper.width,
						textureHelper.height, textureHelper.format, false);
			}else{
				if(_loadingCallbackSet){
					_loadingCallback.apply(this);
					_loadingCallbackSet = false;
					_loadingCallback = null;
				}
			}
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
		override public function drawFrames(time:Number):void {
			//clear previous objects list
			_drawableObjects.length = 0;
			//prepare frame data
			this.prepareDrawObjects();
			_drawableObjects.sort(this.sortMethod);
			this.uploadTextures();
			//throw all errors that was collected
			if(_errorsQueue.length > 0)throw _errorsQueue.shift();
			//draw frame
			super.drawFrames(time);
		}

		private function textureCallback():void {
			_textureLoading = false;
			setTimeout(this.uploadTextures, 0);
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
