/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:47
 */
package com.merlinds.miracle {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;

	public class MiracleTexture {

		public var id:String;
		public var shapes:Vector.<MiracleShape>;
		public var texture:Texture;
		public var size:int;

		public var index:int = -1;

		public function MiracleTexture(textureName:String, textureSize:uint){
			this.id = textureName;
			this.size = textureSize;

			this.shapes = new <MiracleShape>[];
			var layoutData:ByteArray = new ByteArray();
			//TODO need get data
//			Assets.getBytes(Assets.DIR + id + ".json", layoutData)
			var layoutArr:Array = JSON.parse(layoutData.readUTFBytes(layoutData.length)) as Array;
			while(layoutArr.length > 0){
				this.shapes[ this.shapes.length ] = new MiracleShape(layoutArr.shift());
			}

			layoutData = null;
			layoutArr = null;
		}

		public function update(context3d:Context3D):void{
			if(context3d != null){
				var textureData:ByteArray = new ByteArray();
				//TODO need get atf
				//Assets.getBytes(Assets.DIR + id + ".atf", textureData)
				this.texture = context3d.createTexture(size, size, Context3DTextureFormat.BGRA, true);
				texture.uploadCompressedTextureFromByteArray(textureData, 0);
			}
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}
