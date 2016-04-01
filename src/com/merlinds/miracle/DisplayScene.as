/**
 * User: MerlinDS
 * Date: 26.09.2014
 * Time: 18:49
 */
package com.merlinds.miracle
{

	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.fonts.MiracleFonts;
	import com.merlinds.miracle.fonts.MiracleText;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.textures.TextureHelper;
	import com.merlinds.miracle.utils.ContextDisposeState;

	import flash.display3D.Context3DTextureFormat;

	import flash.geom.Point;
	import flash.utils.setTimeout;

	public class DisplayScene extends RenderScene implements IScene
	{

		private static const DELIMITER:String = ".";
		private static const CLONE:String = DELIMITER + "clone";

		private var _displayObjects:Vector.<MiracleDisplayObject>;
		private var _textureNeedToUpload:Vector.<TextureHelper>;
		//loading
		private var _textureLoading:Boolean;
		private var _loadingCallback:Function;
		private var _loadingCallbackSet:Boolean;
		private var _sessionUniqueCounter:int;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function DisplayScene(scale:Number = 1)
		{
			_displayObjects = new <MiracleDisplayObject>[];
			_textureNeedToUpload = new <TextureHelper>[];
			_sessionUniqueCounter = 0;
			super(scale);
		}

		[Inline]
		public final function createImage(mesh:String = null, animation:String = null, frame:uint = 0):MiracleImage
		{
			var instance:MiracleImage = this.createInstance(MiracleImage) as MiracleImage;
			instance.mesh = mesh;
			instance.animation = animation;
			instance.currentFrame = frame;
			return instance as MiracleImage;
		}

		[Inline]
		public final function createAnimation(mesh:String, animation:String, fps:int = 60):MiracleAnimation
		{
			var instance:MiracleAnimation = this.createInstance(MiracleAnimation) as MiracleAnimation;
			instance.mesh = mesh;
			instance.animation = animation;
			instance.currentFrame = 0;
			instance.fps = fps;
			return instance;
		}

		[Inline]
		public final function createTxt(mesh:String, fontName:String, text:String = null):MiracleText
		{
			var instance:MiracleText = this.createInstance(MiracleText) as MiracleText;
			instance.mesh = mesh;
			instance.animation = fontName;
			instance.currentFrame = 0;
			//
			var animation:AnimationHelper = _animations[mesh + DELIMITER + fontName];
			MiracleFonts.miracle_internal::updateGlyphs(fontName, animation);
			instance.animation = instance.miracle_internal::animation + MiracleFonts.FONT_POSTFIX + _sessionUniqueCounter++;
			_animations[instance.animationId] = instance.miracle_internal::animationInstance;
			//
			instance.text = text;
			instance.miracle_internal::demandAnimationInstance = true;
			return instance;
		}

		[Inline]
		public final function createInstance(serializer:Class):MiracleDisplayObject
		{
			var instance:MiracleDisplayObject = new serializer();
			_displayObjects[_displayObjects.length++] = instance;
			if (instance.miracle_internal::demandAnimationInstance)
			{
				//create new animation helper and set it to instance
				var animation:AnimationHelper = _animations[instance.animationId];
				animation = animation.clone();
				instance.animation = instance.miracle_internal::animation + CLONE + _sessionUniqueCounter++;
				_animations[instance.animationId] = animation;
				instance.miracle_internal::animationInstance = animation;
			}
			return instance;
		}

		[Inline]
		public final function removeInstance(instance:MiracleDisplayObject):void
		{
			var index:int = _displayObjects.indexOf(instance);
			if (index > -1)
			{
				_displayObjects.splice(index, 1);
				if (instance.miracle_internal::demandAnimationInstance)
				{
					var animation:AnimationHelper = _animations[instance.animationId];
					animation.dispose();
					delete _animations[instance.animationId];
				}
			}
			instance.miracle_internal::dispose();
			instance.miracle_internal::animationInstance = null;
		}

		[Inline]
		public final function textureInUse(texture:String):Boolean
		{
			var textureHelper:TextureHelper = _textures[texture];
			return textureHelper.inUse;
		}

		[Inline]
		public final function hitTest(point:Point):Object
		{
			// if nothing else is hit, the stage returns itself as target
			var target:MiracleDisplayObject;
			var i:int = _drawableObjects.length;
			while (i-- > 0)
			{
				target = _drawableObjects[i];
				if (target.hitTest(point))
				{
					break;
				}
				target = null;
			}
			return target == null ? this : target;
		}

		public function loadTexturesImmediately(textures:Vector.<String> = null, callback:Function = null):void
		{
			_loadingCallback = callback;
			_loadingCallbackSet = true;
			//load all textures in textures parameter is null
			var textureHelper:TextureHelper;
			if (textures == null)
			{
				for each(textureHelper in _textures)
				{
					if (!textureHelper.uploading && _textureNeedToUpload.indexOf(textureHelper) < 0)
					{
						_textureNeedToUpload[_textureNeedToUpload.length] = textureHelper;
						textureHelper.uploading = true;
					}
				}
			}
			else
			{
				for (var i:int = 0; i < textures.length; i++)
				{
					var name:String = textures[i];
					if (_textures.hasOwnProperty(name))
					{
						textureHelper = _textures[name];
						if (!textureHelper.uploading && _textureNeedToUpload.indexOf(textureHelper) < 0)
						{
							_textureNeedToUpload[_textureNeedToUpload.length] = textureHelper;
							textureHelper.uploading = true;
						}
					}
				}
			}
		}

		override public function restore(callback:Function):void
		{
			_textureLoading = false;
			_drawableObjects.length = 0;
			for each(var textureHelper:TextureHelper in _textures)
			{
				if (textureHelper.inUse)
				{
					//reload texture
					_textureNeedToUpload[_textureNeedToUpload.length] = textureHelper;
					textureHelper.uploading = true;
				}
			}
			_loadingCallbackSet = true;
			_loadingCallback = callback;
			this.uploadTextures();
		}

		override public function stopRestoring():void
		{
			_textureNeedToUpload.length = 0;
			_loadingCallbackSet = false;
			_loadingCallback = null;
			_textureLoading = false;
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		[Inline]
		private final function readyToDraw(instance:MiracleDisplayObject):Boolean
		{
			var meshHelper:Mesh2D;
			var textureHelper:TextureHelper;
			//check instance for mesh and animation field are filed
			if (instance.miracle_internal::mesh == null || instance.miracle_internal::animation == null)return false;
			//check for animation
			if (_animations[instance.animationId] == null)return false;
			//check for necessary objects for current instance
			meshHelper = _meshes[instance.miracle_internal::mesh];

			if (meshHelper == null)
				throw new ArgumentError("Can not draw display object without mesh");

			textureHelper = _textures[meshHelper.textureLink];
			if (textureHelper == null)
				throw new ArgumentError("Can not draw display object without texture");

			//Check for texture
			if (textureHelper.inUse)return true;//CAN BE DRAW Exit point
			//Uploading block, instance could not be draw
			//Texture not in used, check for uploading
			if (!textureHelper.uploading)
			{
				if (_textureNeedToUpload.indexOf(textureHelper) < 0)
				{
					_textureNeedToUpload[_textureNeedToUpload.length] = textureHelper;
					textureHelper.uploading = true;
				}

			}
			return false;
		}

		[Inline]
		private final function uploadTextures():void
		{
			if (_textureLoading)return;
			if (_textureNeedToUpload.length > 0)
			{
				_textureLoading = true;
				if (_context != null && _context.driverInfo != ContextDisposeState.DISPOSED)
				{
					var textureHelper:TextureHelper = _textureNeedToUpload.pop();
					textureHelper.callback = this.textureCallback;
					textureHelper.texture = _context.createTexture(textureHelper.width,
							textureHelper.height, textureHelper.format, false);
				}
				else
				{
					//context can be disposed while texture downloads to GPU memory
					this.enterFrameHandler();
				}

			}
			else
			{
				if (_loadingCallbackSet)
				{
					_loadingCallback.apply(this);
					_loadingCallbackSet = false;
					_loadingCallback = null;
				}
			}
		}

		[Inline]
		private final function sortMethod(a:MiracleDisplayObject, b:MiracleDisplayObject):Number
		{
			if (a.z == b.z)return 0;
			if (a.z < b.z)return 1;
			return -1;//if(a.z > b.z)
		}

		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		override protected final function prepareFrames():void
		{
			//clear previous objects list
			_drawableObjects.length = 0;
			//get all drawable objects
			var instance:MiracleDisplayObject;
			var n:int = _displayObjects.length;
			for (var i:int = 0; i < n; i++)
			{
				instance = _displayObjects[i];
				if (!instance.visible)continue;
				//Only visible instances could be draw
				//check instance for ready to draw
				if (this.readyToDraw(instance))
					_drawableObjects[_drawableObjects.length] = instance;
			}
			//Sort instances by z
			_drawableObjects.sort(this.sortMethod);
			this.uploadTextures();
		}

		[Inline]
		private final function textureCallback():void
		{
			if (this.debuggable)
				trace("Miracle: Texture was loaded to GPU");
			_textureLoading = false;
			setTimeout(this.uploadTextures, 0);
		}

		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		[Inline]
		public final function get displayObjects():Vector.<MiracleDisplayObject>
		{
			return _displayObjects;
		}

		//} endregion GETTERS/SETTERS ==================================================
	}
}
