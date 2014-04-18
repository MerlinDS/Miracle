/**
 * User: MerlinDS
 * Date: 04.04.2014
 * Time: 18:23
 */
package com.merlinds.miracle.materials {
	import com.merlinds.miracle.meshes.Polygon2D;
	import com.merlinds.miracle.miracle_internal;

	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	public final class Material {

		private var _meshList:Vector.<Polygon2D>;

		private var _textureBytes:ByteArray;
		private var _texture:Texture;

		private var _inUse:Boolean;

		/**
		 *  Format of the texture linked to current material
		 *  @default flash.display3D.Context3DTextureFormat.BGRA
		 **/
		private var _textureFormat:String;
		/** Width of the texture linked to current mesh collection.**/
		private var _textureWidth:int;
		/** Height of the texture linked to current mesh collection.**/
		private var _textureHeight:int;
		/** Num  of the texture in ATF linked to current mesh collection.**/
		private var _textureNum:int;



		public function Material(meshCollection:Vector.<Polygon2D>, textureBytes:ByteArray,
		                         textureFormat:String, textureWidth:int, textureHeight:int, textureNum:int) {
			_meshList = meshCollection;
			_textureBytes = textureBytes;
			//add params
			_textureFormat = textureFormat;
			_textureHeight = textureHeight;
			_textureWidth = textureWidth;
			_textureNum = textureNum;
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS

		public function get meshList():Vector.<Polygon2D> {
			return _meshList;
		}

		public function get textureBytes():ByteArray {
			return _textureBytes;
		}

		public function get textureFormat():String {
			return _textureFormat;
		}

		public function get textureWidth():int {
			return _textureWidth;
		}

		public function get textureHeight():int {
			return _textureHeight;
		}

		public function get textureNum():int {
			return _textureNum;
		}

		public function get inUse():Boolean {
			return _inUse;
		}

		public function get texture():Texture {
			return _texture;
		}


		public function set texture(value:Texture):void {
			_texture = value;
			_inUse = true;
		}

		miracle_internal function set inUse(value:Boolean):void {
			_inUse = value;
		}
//} endregion GETTERS/SETTERS ==================================================
	}
}
