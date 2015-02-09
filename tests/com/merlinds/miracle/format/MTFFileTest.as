/**
 * User: MerlinDS
 * Date: 09.02.2015
 * Time: 12:33
 */
package com.merlinds.miracle.format {
	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	public class MTFFileTest extends MTFFile{
		
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MTFFileTest() {
			super("MTF0", "us-ascii");
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
			this.addHeader(2, 2, 1, "ATF");
			var partData:Object = {
				vertices:[0,1,2,3,4,5,6,7],
				uv:[0,1,2,3,4,5,6,7],
				indexes:[0,1,2,3,4,5]
			};
			this.addMesh("anim_0", {part_0:partData, part_1:partData});
			this.addMesh("anim_1", {part_0:partData, part_1:partData, part_2:partData});
			this.addTexture(new FakeATFFile(400));
			Assert.assertFalse("Finalized flag was set before finalization", this.finalized);
			this.finalize();
			Assert.assertTrue("Finalized flag was not set", this.finalized);
			//test header
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
