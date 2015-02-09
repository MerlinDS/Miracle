/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 12:34
 */
package com.merlinds.miracle.format.mtf {
	import com.merlinds.miracle.format.*;
	import com.merlinds.miracle.format.mtf.MTF1;
	import com.merlinds.miracle.format.mtf.MTFHeadersFormat;

	import flexunit.framework.Assert;

	public class MTF1Test {

		//==============================================================================
		//{region							PUBLIC METHODS

		[Test]
		public function testConstructor():void {
			var file:MTF1 = new MTF1();
			var polygonData:Object = {
				vertices:[0, 1, 2, 3, 4, 5, 6, 7],
				uv:[0, 1, 2, 3, 4, 5, 6, 7],
				indexes:[0, 1, 2, 3, 4, 5]
			};
			file.addMesh("test", {test:polygonData});
			file.addTexture(new FakeATFFile(200));
			file.finalize();
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
			Assert.assertEquals("indexes", 1, indexes);
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
