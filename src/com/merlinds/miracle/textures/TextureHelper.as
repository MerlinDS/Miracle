/**
 * User: MerlinDS
 * Date: 18.04.2014
 * Time: 18:33
 */
package com.merlinds.miracle.textures {
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	public class TextureHelper {

		/**
		 *  Format of the texture.
		 *  @default flash.display3D.Context3DTextureFormat.BGRA
		 **/
		public var format:String;
		/** Width of the texture.**/
		public var width:int;
		/** Height of the texture.**/
		public var height:int;
		/** Num  of the texture in ATF.**/
		public var num:int;
		public var inUse:Boolean;

		private var _texture:Texture;
		private var _bytes:ByteArray;
		private var _uploading:Boolean;
		private var _callback:Function;

		public function TextureHelper(bytes:ByteArray) {
			_bytes = bytes;
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		[Inline]
		public final function destroy():void{
			_texture.dispose();
			_texture = null;
			_bytes.clear();
			_bytes = null;
			this.format = null;
			this.width = 0;
			this.height = 0;
			this.num = 0;
			this.inUse = false;
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		[Inline]
		public final function textureReadyHandler(event:Event):void {
			_texture.removeEventListener(event.type, this.textureReadyHandler);
			_uploading = false;
			inUse = true;
			if(_callback is Function){
				setTimeout(_callback.apply, 0);
			}
		}
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		[Inline]
		public final function get texture():Texture {
			return _texture;
		}

		[Inline]
		public final function set texture(value:Texture):void {
			_texture = value;
			_uploading = true;
			_texture.addEventListener(Event.TEXTURE_READY, textureReadyHandler);
			_texture.uploadCompressedTextureFromByteArray(_bytes, 0, true);
		}

		[Inline]
		public final function get uploading():Boolean {
			return _uploading;
		}

		[Inline]
		public final function set uploading(value:Boolean):void {
			_uploading = value;
		}

		[Inline]
		public final function set callback(value:Function):void{
			_callback = value;
		}
//} endregion GETTERS/SETTERS ==================================================
	}
}
