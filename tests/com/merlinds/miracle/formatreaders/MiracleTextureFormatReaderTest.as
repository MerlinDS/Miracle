/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:03
 */
package com.merlinds.miracle.formatreaders {
	import flash.utils.ByteArray;

	public class MiracleTextureFormatReaderTest {

		private var _charSet:String;
		private var _reader:MiracleTextureFormatReader;
		private var _fileBytes:ByteArray;
		//==============================================================================
		//{region							PUBLIC METHODS
		[Before]
		public function setUp():void {
			_charSet = "us-ascii";
			_fileBytes = new TestMTF1File1(_charSet);
			_reader = new MiracleTextureFormatReader(Signatures.MTF1);
		}

		[After]
		public function tearDown():void {
			_fileBytes.clear();
			_fileBytes = null;
			_reader = null;
		}


		[Test(expects="ArgumentError")]
		public function testSignatureError():void {
			var errorBytes:ByteArray = new ByteArray();
			errorBytes.writeMultiByte("ERROR", _charSet);
			_reader.read(errorBytes);
		}

		[Test]
		public function testRead():void {
			_reader.read(_fileBytes);
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}
