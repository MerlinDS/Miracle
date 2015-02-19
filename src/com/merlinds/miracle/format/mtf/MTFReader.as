/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 9:28
 */
package com.merlinds.miracle.format.mtf {
	import com.merlinds.miracle.format.*;
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flash.utils.ByteArray;

	/**
	 * Instance of this class read data from MTF files and parse it for miracle engine.
	 */
	public class MTFReader extends AbstractReader{

		private static const SHORT:int = 1;
//		private static const FLOAT:uint = 2;
//		private static const INT:uint = 3;
		//objects
		private var _header:MTFHeader;
		private var _metadataHeaders:Vector.<MetadataHeader>;
		private var _meshes:Object;
		private var _texture:ByteArray;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MTFReader(signature:String, bytesChunk:int = 8960)
		{
			_metadataHeaders = new <MetadataHeader>[];
			this.addReadingMethod(this.readMetadata);
			this.addReadingMethod(this.readDataBlock);
			this.addReadingMethod(this.prepareForTextureReading);
			this.addReadingMethod(this.readTextureBlock);
			super (signature, bytesChunk);
		}

		/**
		 * Read MTF file and parse it to output
		 * @param bytes MTF file bytes
		 * @param args
		 * <ul>
		 * <li> output object for parsed meshes - Object </li>
		 * <li> output byte array for texture - ByteArray </li>
		 * </ul>
		 *
		 * @throws ArgumentError Bad file signature
		 */
		override public function read(bytes:ByteArray, ...args):void {
			super .read(bytes);
			_meshes = args[0];
			_texture = args[1];
		}

		override public function dispose():void {
			_metadataHeaders.length = 0;
			_texture = null;
			_meshes = null;
			_header = null;
			super.dispose();
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Read file header and parse it to header object
		 */
		override protected function readFileHeader():void {
			_header = new MTFHeader();
			this.bytes.position = MTFHeadersFormat.VT;
			_header.verticesSize = this.bytes.readShort();
			this.bytes.position = MTFHeadersFormat.UVT;
			_header.uvsSize = this.bytes.readShort();
			this.bytes.position = MTFHeadersFormat.IT;
			_header.indexesSize = this.bytes.readShort();
			this.bytes.position = MTFHeadersFormat.TEXTURE_FORMAT;
			_header.textureFormat = this.bytes.readMultiByte(
					MTFHeadersFormat.DATE - MTFHeadersFormat.TEXTURE_FORMAT, this.charSet);
			this.bytes.position = MTFHeadersFormat.DATE;
			_header.modificationDate = this.bytes.readInt();
			this.methodEnded();
		}

		/**
		 * Read metadata of the MTF1 file that contains information about animation names and data array sizes.
		 * Will set flag _endOfMethod equals true when metadata block will be fully read.
		 * </ br>Reading sequence:
		 * </ br>Read animation block name - ControlCharacters.GS
		 * </ br>Read animation part name - ControlCharacters.RS
		 * </ br>Read points array size and indexes array size - ControlCharacters.US
		 * </ br>Read next animation part name - ControlCharacters.RS
		 * </ br>...
		 * </ br>Read next animation block name - ControlCharacters.GS
		 * </ br>...
		 *
		 * Reading will be stopped if ControlCharacters.DLE flag was founded. (End of metadata block)
		 *
		 */
		private function readMetadata():void {
			var headerByte:uint = this.bytes.readByte();
			//get current metadata header if it already added to list
			var metadata:MetadataHeader = _metadataHeaders.length > 0 ?
				_metadataHeaders[_metadataHeaders.length - 1] : null;
			if(headerByte == ControlCharacters.US){
				//read points array size and indexes array size
				var points:uint = this.bytes.readShort();
				var indexes:uint = this.bytes.readShort();
				metadata.sizes.push(points, indexes);
			}else if(headerByte == ControlCharacters.DLE){
				//End of metadata block
				this.methodEnded();
			}else{
				//read animation block name or part of animation name
				var length:int = this.bytes.readShort();
				var name:String = this.bytes.readMultiByte(length, this.charSet);
				if(headerByte == ControlCharacters.GS){
					//add new metadata header
					_metadataHeaders[_metadataHeaders.length] = new MetadataHeader(name);
				}else{
					metadata.parts.push(name);
				}
			}
		}

		/**
		 * Read data from data block that contains information about polygon of the meshes.
		 */
		private function readDataBlock():void {
			//prepare temp data storage
			var vertices:Vector.<Number> = new <Number>[];
			var uvs:Vector.<Number> = new <Number>[];
			var indexes:Vector.<int> = new <int>[];
			//get readMethod for data reading
			var mesh:Mesh2D = new Mesh2D();
			var metadata:MetadataHeader = _metadataHeaders.shift();
			var n:int = metadata.parts.length;//number of polygons
			for(var i:int = 0; i < n; i++){
				var pc:int = metadata.sizes[i * 2] * 2;//points count
				var ic:int = metadata.sizes[i * 2 + 1];//indexes count
				this.readDataList(vertices, _header.verticesSize, pc);
				this.readDataList(uvs, _header.uvsSize, pc);
				this.readDataList(indexes, _header.indexesSize, ic);
				mesh[ metadata.parts[i] ] = new Polygon2D(indexes, vertices, uvs);
				vertices.length = uvs.length = indexes.length = 0;
			}
			_meshes[metadata.name] = mesh;
			metadata.dispose();
			//no more header to read
			if(_metadataHeaders.length == 0)this.methodEnded();
		}

		/**
		 * Read list of data from data block
		 * @param target output for read data
		 * @param type type of the items in list
		 * @param count count of item in list
		 */
		[Inline]
		private final function readDataList(target:Object, type:uint, count:int):void {
			var readMethod:Function = type == SHORT ? this.bytes.readShort : this.bytes.readFloat ;
			for(var i:int = 0; i < count; i++){
				target[i] = readMethod.apply();
			}
		}

		/**
		 * Check for bad file texture or bad texture format
		 * and prepare texture output for reading in it.
		 */
		private function prepareForTextureReading():void {
			//after all data blocks must be a data link escape byte
			this.assert(this.bytes.readByte() == ControlCharacters.DLE, ReaderError.BAD_FILE_STRUCTURE);
			//assert texture format
			var tp:int = this.bytes.position;//save temp position
			var textureFormat:String = this.bytes.readUTFBytes(4);
			this.bytes.position = tp;
			this.assert(_header.textureFormat == textureFormat, ReaderError.BAD_TEXTURE_FORMAT);
			//prepare texture output byte array for writing in it
			_texture.clear();
			_texture.position = 0;
			this.methodEnded();
		}
		/**
		 * Read texture block by chunks will file bytes are available
		 */
		private function readTextureBlock():void {
			if(this.bytes.bytesAvailable > this.bytesChunk){
				this.bytes.readBytes(_texture, _texture.position, this.bytesChunk);
				_texture.position += this.bytesChunk;
			}else{
				this.bytes.readBytes(_texture, _texture.position, this.bytes.bytesAvailable);
				_texture.position = 0;
				this.methodEnded();
			}
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS

		//} endregion GETTERS/SETTERS ==================================================
	}
}

class MetadataHeader{
	/** animation name **/
	public var name:String;
	/** list of animation parts names **/
	public var parts:Vector.<String>;
	/** list of points and indexes arrays length **/
	public var sizes:Vector.<uint>;


	public function MetadataHeader(name:String) {
		this.name = name;
		this.parts = new <String>[];
		this.sizes = new <uint>[];
	}

	public function toString():String {
		return "[MetadataHeader(" +
				"name = " + this.name + "; " +
				"parts = " + this.parts + "; " +
				"sizes = " + this.sizes +
				")]";
	}

	public function dispose():void {
		parts.length = 0;
		sizes.length = 0;
		name = null;
		parts = null;
		sizes = null;
	}
}