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
	public class MTFReader {

		private static const SHORT:int = 1;
//		private static const FLOAT:uint = 2;
//		private static const INT:uint = 3;

		private var _status:int;
		private var _bytesChunk:int;
		private var _charSet:String;
		private var _correctSignature:String;
		private var _endOfMethod:Boolean;
		private var _currentMethod:int;
		private var _readingMethods:Vector.<Function>;
		private var _errors:Vector.<Error>;
		//bytes
		private var _bytes:ByteArray;
		private var _signature:String;
		//objects
		private var _header:MTFHeader;
		private var _metadataHeaders:Vector.<MetadataHeader>;
		private var _meshes:Object;
		private var _texture:ByteArray;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MTFReader(signature:String, bytesChunk:int = 8960) {
			_charSet = "us-ascii";
			_bytesChunk = bytesChunk;
			_correctSignature = signature;
			_metadataHeaders = new <MetadataHeader>[];
			_errors = new <Error>[];
			//initialize methods
			_readingMethods = new <Function>[this.readFileHeader, this.readMetadata,
				this.readDataBlock, this.prepareForTextureReading, this.readTextureBlock];
			_status = ReaderStatus.WAIT;
		}

		/**
		 * Read MTF file and parse it to output
		 * @param bytes MTF file bytes
		 * @param meshes output object for parsed meshes
		 * @param texture output byte array for texture
		 *
		 * @throws ArgumentError Bad file signature
		 */
		public function read(bytes:ByteArray, meshes:Object, texture:ByteArray):void {
			this.dispose();
			_bytes = bytes;
			_meshes = meshes;
			_texture = texture;
			this.assert(_bytes != null, ReaderError.FILE_IS_NULL);
			this.assert(_bytes.length > MTFHeadersFormat.HEADER_SIZE, ReaderError.BAD_FILE_SIZE);
			if(_status != ReaderStatus.ERROR){
				_bytes.position = 0;
				_signature = _bytes.readMultiByte(Signatures.SIZE, _charSet);
				//change status
				_status = ReaderStatus.PROCESSING;
				_currentMethod = 0;
				_endOfMethod = false;
				this.assert(this.isValidSignature, ReaderError.BAD_FILE_SIGNATURE);
			}
		}

		public function readingStep():void {
			if(_status == ReaderStatus.PROCESSING){
				var method:Function = _readingMethods[ _currentMethod ];
				method.apply(this);
				if(_status != ReaderStatus.ERROR){
					if(_endOfMethod)_currentMethod++;
					_endOfMethod = false;
					//reading was ended successfully
					if(_currentMethod == _readingMethods.length){
						_status = ReaderStatus.READY;
					}
				}
			}
		}

		public function dispose():void {
			_metadataHeaders.length = 0;
			_errors.length = 0;
			_signature = null;
			_texture = null;
			_meshes = null;
			_header = null;
			_bytes = null;
			//set new status
			_status = ReaderStatus.WAIT;
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Read file header and parse it to header object
		 */
		private function readFileHeader():void {
			_header = new MTFHeader();
			_bytes.position = MTFHeadersFormat.VT;
			_header.verticesSize = _bytes.readShort();
			_bytes.position = MTFHeadersFormat.UVT;
			_header.uvsSize = _bytes.readShort();
			_bytes.position = MTFHeadersFormat.IT;
			_header.indexesSize = _bytes.readShort();
			_bytes.position = MTFHeadersFormat.TEXTURE_FORMAT;
			_header.textureFormat = _bytes.readMultiByte(
					MTFHeadersFormat.DATE - MTFHeadersFormat.TEXTURE_FORMAT, _charSet);
			_bytes.position = MTFHeadersFormat.DATE;
			_header.modificationDate = _bytes.readInt();
			_endOfMethod = true;
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
			var headerByte:uint = _bytes.readByte();
			//get current metadata header if it already added to list
			var metadata:MetadataHeader = _metadataHeaders.length > 0 ?
				_metadataHeaders[_metadataHeaders.length - 1] : null;
			if(headerByte == ControlCharacters.US){
				//read points array size and indexes array size
				var points:uint = _bytes.readShort();
				var indexes:uint = _bytes.readShort();
				metadata.sizes.push(points, indexes);
			}else if(headerByte == ControlCharacters.DLE){
				//End of metadata block
				_endOfMethod = true;
			}else{
				//read animation block name or part of animation name
				var length:int = _bytes.readShort();
				var name:String = _bytes.readMultiByte(length, _charSet);
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
			_endOfMethod = _metadataHeaders.length == 0;
		}

		/**
		 * Read list of data from data block
		 * @param target output for read data
		 * @param type type of the items in list
		 * @param count count of item in list
		 */
		[Inline]
		private final function readDataList(target:Object, type:uint, count:int):void {
			var readMethod:Function = type == SHORT ? _bytes.readShort : _bytes.readFloat ;
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
			this.assert(_bytes.readByte() == ControlCharacters.DLE, ReaderError.BAD_FILE_STRUCTURE);
			//assert texture format
			var tp:int = _bytes.position;//save temp position
			var textureFormat:String = _bytes.readUTFBytes(4);
			_bytes.position = tp;
			this.assert(_header.textureFormat == textureFormat, ReaderError.BAD_TEXTURE_FORMAT);
			//prepare texture output byte array for writing in it
			_texture.clear();
			_texture.position = 0;
			_endOfMethod = true;
		}
		/**
		 * Read texture block by chunks will file bytes are available
		 */
		private function readTextureBlock():void {
			if(_bytes.bytesAvailable > _bytesChunk){
				_bytes.readBytes(_texture, _texture.position, _bytesChunk);
				_texture.position += _bytesChunk;
			}else{
				_bytes.readBytes(_texture, _texture.position, _bytes.bytesAvailable);
				_texture.position = 0;
				_endOfMethod = true;
			}
		}

		/**
		 * Error assertion method
		 * @param condition
		 * @param errorId
		 */
		private function assert(condition:Boolean, errorId:int = 0):void {
			if(!condition){
				_errors[_errors.length] = ReaderError.castError(errorId);
				_status = ReaderStatus.ERROR;
			}
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		/** Check for file signature correctness. Return true if signature is correct, false in other case **/
		public function get isValidSignature():Boolean {
			return _signature == _correctSignature;
		}

		/**
		 * Get reader status.
		 * @see com.merlinds.miracle.format.ReaderStatus
		 */
		public function get status():int {
			return _status;
		}

		public function get errors():Vector.<Error> {
			return _errors;
		}
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