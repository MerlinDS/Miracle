/**
 * User: MerlinDS
 * Date: 18.07.2014
 * Time: 18:22
 */
package com.merlinds.miracle.utils {
	import com.merlinds.miracle.meshes.Mesh2D;
	import com.merlinds.miracle.meshes.Polygon2D;
	import com.merlinds.miracle.textures.TextureHelper;

	import flash.utils.ByteArray;

	public class MtfReader {

		public static const MESH_BLOCK_SIZE:int = 512;

		private var _mesh:Mesh2D;
		private var _texture:TextureHelper;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MtfReader() {
		}

		public function execute(bytes:ByteArray, scale:Number):void {
			//ignore signature
			bytes.position = 4;
			//read mesh header length
			var meshSize:int = bytes.readUnsignedInt() * MESH_BLOCK_SIZE;
			//read mesh data
			bytes.position = 8;
			var meshData:Array = bytes.readObject();
			//read texture bytes
			bytes.position = 8 + meshSize;
			var textureBytes:ByteArray = new ByteArray();
			bytes.readBytes(textureBytes, 0, bytes.length - bytes.position);
			bytes.clear();
			//parse meshes
			var mesh:Mesh2D = new Mesh2D();
			var n:int = meshData.length;
			for(var i:int = 0; i < n; i++){
				mesh[i] = new Polygon2D(meshData[i], scale);
			}
			_mesh = mesh;
			//parse textures
			_texture = new TextureHelper( textureBytes );
			AtfData.getAtfParameters( textureBytes, _texture );
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

		public function get mesh():Mesh2D {
			return _mesh;
		}

		public function get texture():TextureHelper {
			return _texture;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
