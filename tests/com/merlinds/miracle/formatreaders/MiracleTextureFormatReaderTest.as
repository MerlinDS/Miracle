/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:03
 */
package com.merlinds.miracle.formatreaders {
	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	public class MiracleTextureFormatReaderTest {

		private var _charSet:String;
		private var _reader:MiracleTextureFormatReader;
		private var _fileBytes:ByteArray;
		//==============================================================================
		//{region							PUBLIC METHODS
		[Before]
		public function setUp():void {
			_charSet = "us-ascii";
			var atf:FakeATFFile = new FakeATFFile(300);
			var file:TestMTF1File1 = new TestMTF1File1(_charSet);
			file.writeMTF1Header();

			file.writeAnimationName("ball");
			file.writeAnimationPartName("ball_image");
			file.writeAnimationSizes(4, 6);

			file.writeAnimationName("shapes");
			file.writeAnimationPartName("circle");
			file.writeAnimationSizes(4, 6);
			file.writeAnimationPartName("rect");
			file.writeAnimationSizes(4, 6);
			file.writeDataEscape();

			for(var i:int = 0; i < 3; i++){
				file.writeFloatArray(0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0);
				file.writeFloatArray(0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0);
				file.writeShortArray(0, 1, 2, 3, 4, 5);
			}

			file.writeDataEscape();
			file.writeBytes(atf, 0, atf.length);

			_fileBytes = file;
			_reader = new MiracleTextureFormatReader(Signatures.MTF1);
		}

		[After]
		public function tearDown():void {
			_fileBytes.clear();
			_fileBytes = null;
			_reader = null;
		}


		[Test]
		public function testSignatureError():void {
			var errorBytes:ByteArray = new ByteArray();
			errorBytes.writeMultiByte("ERROR", _charSet);
			_reader.read(errorBytes, {}, null);
			_reader.readingStep();
			Assert.assertEquals("Error of signature was not occurred", ReaderStatus.ERROR, _reader.status);
			Assert.assertFalse("Signature must be invalid", _reader.isValidSignature);
			Assert.assertEquals("Error list is empty", 1, _reader.errors.length);
		}

		[Test(async)]
		public function testRead():void {
			var meshes:Object = {};
			var texture:ByteArray = new ByteArray();
			_reader.read(_fileBytes, meshes, texture);
			while(_reader.status == ReaderStatus.PROCESSING){
				_reader.readingStep();
			}
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
