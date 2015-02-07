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

		private var _charSet:String;
		private var _correctSignature:String;
		//bytes
		private var _bytes:ByteArray;
		private var _buffer:ByteArray;
		private var _signatureBytes:ByteArray;
		//objects
		private var _header:MTFHeader;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleTextureFormatReader(signature:String) {
			_charSet = "us-ascii";
			_correctSignature = signature;
			_buffer = new ByteArray();
			_signatureBytes = new ByteArray();
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
			this.readFileHeader();
			trace(_header);//TODO remove after developing
			//read likes block and prepare for data block reading
			//start read data block
			//read texture bytes
		}

		public function dispose():void {
			_signatureBytes.clear();
			_signatureBytes.position = 0;
			_buffer.clear();
			_buffer.position = 0;
			_header = null;
			_bytes = null;
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}
