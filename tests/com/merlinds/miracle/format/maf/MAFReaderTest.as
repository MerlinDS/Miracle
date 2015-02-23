/**
 * User: MerlinDS
 * Date: 23.02.2015
 * Time: 16:23
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.format.Signatures;

	import flash.geom.Rectangle;

	import flash.utils.ByteArray;

	public class MAFReaderTest {

		private var _charSet:String;
		private var _reader:MAFReader;
		private var _maf1:ByteArray;
		//==============================================================================
		//{region							PUBLIC METHODS

		[Before]
		public function setUp():void {
			_charSet = "us-ascii";
			_reader = new MAFReader(Signatures.MAF1, 256);
			var maf:MAF1 = new MAF1();
		}

		[Test]
		public function testRead():void {

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
