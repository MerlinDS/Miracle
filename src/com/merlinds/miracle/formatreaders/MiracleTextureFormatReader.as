/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 9:28
 */
package com.merlinds.miracle.formatreaders {
	import flash.utils.ByteArray;

	/**
	 * Instance of this class read data from MTF files and parse it for miracle engine.
	 */
	public class MiracleTextureFormatReader {

		private var _status:int;
		private var _charSet:String;
		private var _correctSignature:String;
		private var _endOfBlock:Boolean;
		//bytes
		private var _bytes:ByteArray;
		private var _signatureBytes:ByteArray;
		//objects
		private var _header:MTFHeader;
		private var _metadataHeaders:Vector.<MetadataHeader>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleTextureFormatReader(signature:String) {
			_charSet = "us-ascii";
			_correctSignature = signature;
			_signatureBytes = new ByteArray();
			_metadataHeaders = new <MetadataHeader>[];
			_status = ReaderStatus.WAIT;
		}

		/**
		 * Read MTF file and parse it to output
		 * @param bytes MTF file bytes
		 *
		 * @throws ArgumentError Bad file signature
		 */
		public function read(bytes:ByteArray):void {
			this.dispose();
			_bytes = bytes;
			_bytes.position = 0;
			_bytes.readBytes(_signatureBytes, 0, Signatures.SIZE);
			if(this.isValidSignature == false){
				throw new ArgumentError("Can't read file with current signature. Bad file signature");
			}
			//change status
			_status = ReaderStatus.PROCESSING;
			this.readFileHeader();
			trace(_header);//TODO remove after developing
			//read metadata
			while(!_endOfBlock)this.readMetadata();
			trace(_metadataHeaders);
			this.readDataBlock();
			this.readTextureBlock();
		}

		public function dispose():void {
			_signatureBytes.clear();
			_signatureBytes.position = 0;
			_metadataHeaders.length = 0;
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
			_bytes.position = TextureHeadersFormat.VT;
			_header.verticesSize = _bytes.readShort();
			_bytes.position = TextureHeadersFormat.UVT;
			_header.uvsSize = _bytes.readShort();
			_bytes.position = TextureHeadersFormat.IT;
			_header.indexesSize = _bytes.readShort();
			_bytes.position = TextureHeadersFormat.TEXTURE_FORMAT;
			_header.textureFormat = _bytes.readMultiByte(
					TextureHeadersFormat.DATE - TextureHeadersFormat.TEXTURE_FORMAT, _charSet);
			_bytes.position = TextureHeadersFormat.DATE;
			_header.modificationDate = _bytes.readInt();
		}

		/**
		 * Read metadata of the MTF1 file that contains information about animation names and data array sizes.
		 * Will set flag _endOfBlock equals true when metadata block will be fully read.
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
				_endOfBlock = true;
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

		private function readDataBlock():void {
			//read vertices list
		}

		private function readTextureBlock():void {

		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get isValidSignature():Boolean {
			_signatureBytes.position = 0;
			return _signatureBytes.readMultiByte(Signatures.SIZE, _charSet) == _correctSignature;
		}

		public function get status():int {
			return _status;
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
}