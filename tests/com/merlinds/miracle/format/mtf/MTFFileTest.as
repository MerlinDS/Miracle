/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 12:33
 */
package com.merlinds.miracle.format.mtf {
	import com.merlinds.miracle.format.*;
	import com.merlinds.miracle.format.mtf.MTFFile;
	import com.merlinds.miracle.format.mtf.MTFHeadersFormat;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	public class MTFFileTest extends MTFFile{

		private var _signature:String;
		private var _charSet:String;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MTFFileTest() {
			_signature = "MTF0";
			_charSet = "us-ascii";
			super(_signature, _charSet);
		}


		[Test(expects="flash.errors.IllegalOperationError")]
		public function testHeaderSizesError():void {
			this.finalize();
		}

		[Test(expects="flash.errors.IllegalOperationError")]
		public function testHeaderTextureFormatError():void {
			this.addHeader(2, 2, 1, null);
			this.finalize();
		}

		[Test(expects="flash.errors.IllegalOperationError")]
		public function testHeaderMeshesError():void {
			this.addHeader(2, 2, 1, "ATF");
			this.finalize();
		}

		[Test(expects="flash.errors.IllegalOperationError")]
		public function testHeaderTextureError():void {
			this.addHeader(2, 2, 1, "ATF");
			var partData:Object = {
				vertices:[0,1,2,3,4,5,6,7],
				uv:[0,1,2,3,4,5,6,7],
				indexes:[0,1,2,3,4,5]
			};
			this.addMesh("anim_0", {part:partData});
			this.finalize();
		}

		[Test(expects="ArgumentError")]
		public function testMeshAddingError():void {
			this.addHeader(2, 2, 1, "ATF");
			this.addMesh("anim_0", {});
		}

		[Test(expects="ArgumentError")]
		public function testMeshFieldError():void {
			this.addHeader(2, 2, 1, "ATF");
			var partData:Object = {
				vertices:[0,1,2,3,4,5,6,7],
				uv:[0,1,2,3,4,5,6,7]
			};
			this.addMesh("anim_0", {part:partData});
		}

		[Test(expects="ArgumentError")]
		public function testTextureAddingError():void {
			this.addHeader(2, 2, 1, "ATF");
			var partData:Object = {
				vertices:[0,1,2,3,4,5,6,7],
				uv:[0,1,2,3,4,5,6,7],
				indexes:[0,1,2,3,4,5]
			};
			this.addMesh("anim_0", {part:partData});
			var errorTexture:ByteArray = new ByteArray();
			errorTexture.writeUTFBytes("ERRO");
			this.addTexture(errorTexture);
		}

		[Test(expects="ArgumentError")]
		public function testTextureNullError():void {
			this.addHeader(2, 2, 1, "ATF");
			var partData:Object = {
				vertices:[0,1,2,3,4,5,6,7],
				uv:[0,1,2,3,4,5,6,7],
				indexes:[0,1,2,3,4,5]
			};
			this.addMesh("anim_0", {part:partData});
			this.addTexture(null);
		}


		[Test]
		public function testNormalFinalization():void {
			var tf:String = "ATF";
			var vs:int = 2;
			var uvs:int = 2;
			var ins:int = 1;
			this.addHeader(vs, uvs, ins, tf);
			var anim_0_part_0:Object = this.getUniqueData();
			var anim_0_part_1:Object = this.getUniqueData();
			var anim_1_part_0:Object = this.getUniqueData();
			this.addMesh("anim_0", {part_0:anim_0_part_0, part_1:anim_0_part_1});
			this.addMesh("anim_1", {part_0:anim_1_part_0});
			var atf:ByteArray = new FakeATFFile(400);
			this.addTexture(atf);
			Assert.assertFalse("Finalized flag was set before finalization", this.finalized);
			this.finalize();
			Assert.assertTrue("Finalized flag was not set", this.finalized);
			this.position = 0;
			//test header
			var signature:String = this.readMultiByte(_signature.length, _charSet);
			this.position = MTFHeadersFormat.VT;
			var verticesSize:int = this.readShort();
			var uvsSizes:int = this.readShort();
			var indexesSizes:int = this.readShort();
			var textureFormat:String = this.readMultiByte(tf.length, _charSet);
			this.position = MTFHeadersFormat.TEXTURE_FORMAT;
			Assert.assertEquals("Signature", _signature, signature);
			Assert.assertEquals("verticesSize", vs, verticesSize);
			Assert.assertEquals("uvsSizes", uvs, uvsSizes);
			Assert.assertEquals("indexesSizes", ins, indexesSizes);
			Assert.assertEquals("textureFormat", tf, textureFormat);

			var testData:Array = [];
			//test meta
			var byte:uint;
			var length:uint;
			var string:String;
			this.position = MTFHeadersFormat.HEADER_SIZE;
			byte = this.readByte();
			Assert.assertEquals("First flag", ControlCharacters.GS, byte);
			length = this.readShort();
			string = this.readMultiByte(length, _charSet);
			Assert.assertEquals("First gs", "anim_0", string);
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.RS, byte);
			length = this.readShort();
			string = this.readMultiByte(length, _charSet);
			Assert.assertTrue("part_0 || part_1 = " + string, string == "part_0" || string == "part_1");
			testData[0] = string == "part_0" ? anim_0_part_0 : anim_0_part_1;
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.US, byte);
			Assert.assertEquals("points", 4, this.readShort());
			Assert.assertEquals("indexes", 6, this.readShort());
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.RS, byte);
			length = this.readShort();
			string = this.readMultiByte(length, _charSet);
			Assert.assertTrue("part_0 || part_1 = " + string, string == "part_0" || string == "part_1");
			testData[1] = string == "part_0" ? anim_0_part_0 : anim_0_part_1;
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.US, byte);
			Assert.assertEquals("points", 4, this.readShort());
			Assert.assertEquals("indexes", 6, this.readShort());

			byte = this.readByte();
			Assert.assertEquals("Second flag", ControlCharacters.GS, byte);
			length = this.readShort();
			string = this.readMultiByte(length, _charSet);
			Assert.assertEquals("Second gs", "anim_1", string);
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.RS, byte);
			length = this.readShort();
			string = this.readMultiByte(length, _charSet);
			Assert.assertTrue("part_0 " + string, string == "part_0");
			testData[2] = anim_1_part_0;
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.US, byte);
			Assert.assertEquals("points", 4, this.readShort());
			Assert.assertEquals("indexes", 6, this.readShort());
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.DLE, byte);
			//
			//test data
			var j:int;
			var n:int = testData.length;
			for(var i:int = 0; i < n; i++){
				var item:Object = testData[i];
				var dataRead:Array = [];
				for(j = 0; j < 8; j++)dataRead[j] = this.readFloat();
				Assert.assertContained("vertices", item.vertices, dataRead);
				dataRead.length = 0;
				for(j = 0; j < 8; j++)dataRead[j] = this.readFloat();
				Assert.assertContained("uv", item.uv, dataRead);
				dataRead.length = 0;
				for(j = 0; j < 6; j++)dataRead[j] = this.readShort();
				Assert.assertContained("indexes", item.indexes, dataRead);
			}
			byte = this.readByte();
			Assert.assertEquals(ControlCharacters.DLE, byte);

			//test ATF
			var testAtf:ByteArray = new ByteArray();
			this.readBytes(testAtf);
			atf.position = testAtf.position = 0;
			n = testAtf.length;
			for(i = 0; i < n; i++){
				if(atf.readByte() != testAtf.readByte())
					Assert.fail("ATFs bytes mot equals");
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
		private var _usedSeed:Vector.<int> = new <int>[];

		private function getUniqueData():Object {
			do
				var seed:int = Math.random() * 100;
			while(_usedSeed.indexOf(seed) > -1);
			_usedSeed.push(seed);

			var data:Object = {
				vertices:[0,1,2,3,4,5,6,7],
				uv:[0,1,2,3,4,5,6,7],
				indexes:[0,1,2,3,4,5]
			};
			var i:int, n:int;
			n = data.vertices.length;
			for(i = 0; i < n; i++){
				data.vertices[i] += seed;
			}
			n = data.uv.length;
			for(i = 0; i < n; i++){
				data.uv[i] += seed;
			}
			n = data.indexes.length;
			for(i = 0; i < n; i++){
				data.vertices[i] += seed;
			}

			return data;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
