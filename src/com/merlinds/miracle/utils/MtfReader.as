/**
 * User: MerlinDS
 * Date: 18.07.2014
 * Time: 18:22
 */
package com.merlinds.miracle.utils {

	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;
	import com.merlinds.miracle.textures.TextureHelper;

	import flash.utils.ByteArray;
	import flash.utils.setTimeout;

	public class MtfReader {

		public static const MESH_BLOCK_SIZE:int = 512;

		private var _meshes:Object;
		private var _texture:TextureHelper;
		private var _callback:Function;

		private var _textureBytes:ByteArray;
		private var _meshesData:Array;
		private var _scale:Number;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MtfReader() {
		}

		public function execute(bytes:ByteArray, scale:Number, callback:Function):void
		{
			this.readData(bytes);
			_callback = callback;
			_scale = scale;

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function readData(bytes:ByteArray):void
		{
			//ignore signature
			bytes.position = 4;
			//read mesh header length
			var meshSize:int = bytes.readUnsignedInt() * MESH_BLOCK_SIZE;
			//read mesh data
			bytes.position = 8;
			_meshesData = bytes.readObject();
			//read texture bytes
			bytes.position = 8 + meshSize;
			_textureBytes = new ByteArray();
			bytes.readBytes(_textureBytes, 0, bytes.length - bytes.position);
			bytes.clear();
			setTimeout(parse, 1);
		}

		private function parse():void
		{
			//parse meshes2D
			_meshes = {};
			var n:int = _meshesData.length;
			for(var i:int = 0; i < n; i++){
				var meshData:Object = _meshesData[i];
				var m:int = meshData.mesh.length;
				var mesh:Mesh2D = new Mesh2D();
				//read polygons
				for(var j:int = 0; j < m; j++){
					var name:String = meshData.mesh[j].name;
					mesh[name] = new Polygon2D(meshData.mesh[j], _scale);
				}
				meshes[meshData.name] = mesh;
			}
			//parse textures
			_texture = new TextureHelper( _textureBytes );
			AtfData.getAtfParameters( _textureBytes, _texture );
			_textureBytes = null;
			_meshesData = null;
			_callback.call();
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS

		public function get meshes():Object {
			return _meshes;
		}

		public function get texture():TextureHelper {
			return _texture;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
