/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 12:34
 */
package com.merlinds.miracle.format {
	import flexunit.framework.Assert;

	public class MTF1Test {

		//==============================================================================
		//{region							PUBLIC METHODS

		[Test]
		public function testConstructor():void {
			var file:MTF1 = new MTF1();
			file.position = 0;
			var charSet:String = "us-ascii";
			var signature:String = file.readMultiByte(MTFHeadersFormat.VT, charSet);
			var vertices:int = file.readShort();
			var uvs:int = file.readShort();
			var indexes:int = file.readShort();
			var textureFormat:String = file.readMultiByte(MTFHeadersFormat.DATE, charSet);
			var dateOfCreation:Number = file.readInt();
			Assert.assertEquals("Signature", Signatures.MTF1, signature);
			Assert.assertEquals("vertices", 2, vertices);
			Assert.assertEquals("uvs", 2, uvs);
			Assert.assertEquals("indexes", 2, indexes);
			Assert.assertEquals("textureFormat", "ATF", textureFormat);
			Assert.assertNotNull("dateOfCreation", dateOfCreation);

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