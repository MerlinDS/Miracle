/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 12:16
 */
package com.merlinds.miracle.format {
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;

	internal class MTFFile extends ByteArray {

		private var _charSet:String;
		private var _signature:String;

		private var _meshesOrder:Vector.<String>;
		private var _meshes:Object;
		private var _texture:ByteArray;
		private var _header:MTFHeader;
		private var _finalized:Boolean;
		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param signature File signature
		 * @param charSet Characters set
		 */
		public function MTFFile(signature:String, charSet:String) {
			_signature = signature;
			_charSet = charSet;
			_meshes = {};
			_meshesOrder = new <String>[];
			_header = new MTFHeader();
			super();
		}

		/**
		 * Add mesh to MTF file.
		 * Will be not written till finalize method not executed.
		 * @param name Name of the mesh
		 * @param mesh Mesh object, must contain polygons objects with fields:
		 * <ul>
		 *     <li>vertices</li>
		 *     <li>uv</li>
		 *     <indexes>indexes</li>
		 * </ul>
		 * @throws ArgumentError Polygon has no necessary filed
		 * @throws ArgumentError Mesh has no polygons
		 */
		public function addMesh(name:String, mesh:Object):void {
			//data verification
			var empty:Boolean = true;
			for each(var polygon:Object in mesh){
				if(!polygon.hasOwnProperty("vertices") ||
					!polygon.hasOwnProperty("uv") ||
					!polygon.hasOwnProperty("indexes")
				){
					throw new ArgumentError("Polygon has no necessary filed");
				}
				empty = false;
			}
			if(empty)
				throw new ArgumentError("Mesh has no polygons");
			//data is fine and can be added
			_meshes[name] = mesh;
			_meshesOrder.push(name);
		}

		/**
		 * Add texture to MTF file.
		 * @param texture Bytes of the texture.
		 *
		 * Can be only one texture for MTF file.
		 *
		 * @throws ArgumentError Texture can not be null
		 * @throws ArgumentError Texture has bad format
		 */
		public function addTexture(texture:ByteArray):void {
			//texture verification
			if (texture == null)
				throw new ArgumentError("Texture can not be null");
			texture.position = 0;
			var format:String = texture.readUTFBytes(4);
			if(format != _header.textureFormat)
				throw new ArgumentError("Texture has bad format");
			//texture is fine and can be added
			_texture = texture;
		}

		/**
		 * Finalize MTF file.
		 * Write all data to file bytes.
		 */
		public function finalize():void {
			//validate header
			if(_header.indexesSize == 0 || _header.verticesSize == 0 || _header.uvsSize == 0)
				throw new IllegalOperationError("Header contains 0 type of size fields");
			if(_header.textureFormat == null)
				throw new IllegalOperationError("Header not contains texture format");
			if(_header.modificationDate == 0)
				throw new IllegalOperationError("Modification date can not be null");
			//validate meshes
			var n:String;
			var empty:Boolean = true;
			for(n in _meshes){ empty = false; break; }
			if(empty)
				throw new IllegalOperationError("Meshes was not set");
			if(_texture == null)
				throw new IllegalOperationError("Texture was not set");
			//finalize
			this.writeHeader();
			this.writeMeshes();
			this.writeTexture();
			//free memory
			_header = new MTFHeader();
			_meshes = {};
			_texture = null;

			_finalized = true;
		}

		override public function clear():void {
			super.clear();
			_header = new MTFHeader();
			_meshesOrder.length = 0;
			_meshes = {};
			_texture = null;
			_finalized = false;
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Add Header of the MTF file.
		 * @param vertices vertices list element type
		 * @param uvs uvs list element type
		 * @param indexes indexes list element type
		 * @param texture Texture format
		 *
		 * Will be not written till finalize method not executed.
		 */
		protected final function addHeader(vertices:uint, uvs:uint, indexes:uint,
		                                texture:String):void
		{
			_header.verticesSize = vertices;
			_header.uvsSize = uvs;
			_header.indexesSize = indexes;
			_header.textureFormat = texture;
			_header.modificationDate = new Date().getTime();
		}

		private function writeHeader():void {
			this.writeMultiByte(_signature, _charSet);
			this.position = MTFHeadersFormat.VT;
			this.writeShort(_header.verticesSize);//Write vertices list element type = float
			this.writeShort(_header.uvsSize);//Write uvs list element type = float
			this.writeShort(_header.indexesSize);//Write indexes list element type = float
			this.writeMultiByte(_header.textureFormat, _charSet);//Write texture format
			this.position = MTFHeadersFormat.DATE;
			this.writeInt(_header.modificationDate);//Write creation time
		}

		private function writeMeshes():void {
			var meshesBlock:ByteArray = new ByteArray();
			var dataBlock:ByteArray = new ByteArray();
			for each(var n:String in _meshesOrder){
				var mesh:Object = _meshes[n];
				meshesBlock.writeByte(ControlCharacters.GS);
				//write block length
				meshesBlock.writeShort(n.length);
				meshesBlock.writeMultiByte(n, _charSet);
				//write mesh
				for(var m:String in mesh){
					meshesBlock.writeByte(ControlCharacters.RS);
					//write block length
					meshesBlock.writeShort(m.length);
					meshesBlock.writeMultiByte(m, _charSet);
					//write polygon
					meshesBlock.writeByte(ControlCharacters.US);
					meshesBlock.writeShort(mesh[m].uv.length / 2 );
					meshesBlock.writeShort(mesh[m].indexes.length );
					this.writeDataToTarget(mesh[m], dataBlock);
				}
			}
			this.position = MTFHeadersFormat.HEADER_SIZE;
			this.writeBytes(meshesBlock, 0, meshesBlock.length);
			this.writeByte(ControlCharacters.DLE);
			this.writeBytes(dataBlock, 0, dataBlock.length);
		}

		private function writeDataToTarget(data:Object, target:ByteArray):void {
			//write vertices
			var method:Function = _header.verticesSize != 1 ? target.writeFloat : target.writeShort;
			var i:int, n:int = data.vertices.length;
			for(i = 0; i < n; i++){
				method.apply(this, [data.vertices[i]]);
			}
			//write uvs
			method = _header.uvsSize != 1 ? target.writeFloat : target.writeShort;
			n = data.uv.length;
			for(i = 0; i < n; i++){
				method.apply(this, [data.uv[i]]);
			}
			//write indexes
			method = _header.indexesSize != 1 ? target.writeFloat : target.writeShort;
			n = data.indexes.length;
			for(i = 0; i < n; i++){
				method.apply(this, [data.indexes[i]]);
			}
		}

		private function writeTexture():void {
			this.writeByte(ControlCharacters.DLE);
			this.writeBytes(_texture, 0, _texture.length);
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		/** Return flag of finalization.
		 * If flag equals true, file are finalized,
		 * all data was written to bytes and file can be saved to disk as MTF file.
		 * In other case file was not finalized and has no written data.
		 **/
		public function get finalized():Boolean {
			return _finalized;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}