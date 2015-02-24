/**
 * User: MerlinDS
 * Date: 23.02.2015
 * Time: 16:23
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.format.ReaderStatus;
	import com.merlinds.miracle.format.Signatures;
	import com.merlinds.miracle.format.maf.mocks.MockData;

	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	public class MAFReaderTest {

		private var _charSet:String;
		private var _reader:MAFReader;
		private var _maf1:ByteArray;
		private var _mock:MockData;
		//==============================================================================
		//{region							PUBLIC METHODS

		[Before]
		public function setUp():void {
			_charSet = "us-ascii";
			_reader = new MAFReader(Signatures.MAF1, 6);
			var maf:MAF1 = new MAF1();
			_mock = new MockData();
			_mock.addDataToFile(maf);
			maf.finalize();
			_maf1 = maf;
		}

		[Test]
		public function testRead():void {
			var animations:Object = {};
			Assert.assertEquals("Reader was not set to read yet", ReaderStatus.WAIT, _reader.status);
			_reader.read(_maf1, animations);
			Assert.assertEquals("Reader status must equals PROCESSING", ReaderStatus.PROCESSING, _reader.status);
			Assert.assertTrue("Signature must be valid", _reader.isValidSignature);
			while(_reader.status == ReaderStatus.PROCESSING){
				_reader.readingStep();
			}
			Assert.assertEquals("Reader status must equals READY: " + _reader.errors[0]
					, ReaderStatus.READY, _reader.status);

			Assert.fail("Test not yet implemented");
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
