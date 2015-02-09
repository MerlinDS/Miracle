/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:03
 */
package com.merlinds.miracle.format {
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;

	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	public class MTFReaderTest {

		private var _charSet:String;
		private var _reader:MTFReader;
		private var _mtf1:ByteArray;

		private var _texture:ByteArray;
		private var _textureSize:int;

		private var _meshes:Object;
		//==============================================================================
		//{region							PUBLIC METHODS
		[Before]
		public function setUp():void {
			_charSet = "us-ascii";
			_textureSize = 4000;

			var polygonData:Object = {
				vertices:[0, 1, 2, 3, 4, 5, 6, 7],
				uv:[0, 1, 2, 3, 4, 5, 6, 7],
				indexes:[0, 1, 2, 3, 4, 5]
			};

			_meshes = {
				mesh_0:{
					polygon_0:polygonData
				},
				mesh_1:{
					polygon_0:polygonData,
					polygon_1:polygonData
				},
				mesh_2:{
					polygon_0:polygonData,
					polygon_1:polygonData,
					polygon_3:polygonData
				}
			};
			_texture = new FakeATFFile(_textureSize);
			var mtf1:MTF1 = new MTF1();
			mtf1.addTexture(_texture);

			for(var m:String in _meshes){
				mtf1.addMesh(m, _meshes[m]);
			}

			mtf1.finalize();
			_mtf1 = mtf1;
			_reader = new MTFReader(Signatures.MTF1, 256);
		}

		[After]
		public function tearDown():void {
			_mtf1.clear();
			_mtf1 = null;
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

		[Test]
		public function testRead():void {
			var meshes:Object = {};
			var texture:ByteArray = new ByteArray();
			Assert.assertEquals("Reader was not set to read yet", ReaderStatus.WAIT, _reader.status);
			_reader.read(_mtf1, meshes, texture);
			Assert.assertEquals("Reader status must equals PROCESSING", ReaderStatus.PROCESSING, _reader.status);
			Assert.assertTrue("Signature must be valid", _reader.isValidSignature);
			while(_reader.status == ReaderStatus.PROCESSING){
				_reader.readingStep();
			}
			Assert.assertEquals("Reader status must equals READY", ReaderStatus.READY, _reader.status);
			var buffer:Vector.<Number> = new <Number>[0,1,0,1,2,3,2,3,4,5,4,5,6,7,6,7];
			var indexes:Vector.<int> = new <int>[0,1,2,3,4,5];
			for(var m:String in _meshes){
				var mesh:Mesh2D = this.findFieldInObject(meshes, m);
				Assert.assertNotNull("Mesh " + m + " was not found in output", mesh);
				for(var p:String in meshes[m]){
					var polygon:Polygon2D = this.findFieldInObject(mesh, p);
					Assert.assertNotNull("Polygon " + p + " was not found in mesh", polygon);
					Assert.assertContained("Buffer is bad", buffer, polygon.buffer);
					Assert.assertContained("Indexes is bad", indexes, polygon.indexes);
				}
			}

			Assert.assertNotNull("Texture was not destructed", texture);
			Assert.assertEquals("Texture size is bad", _textureSize, texture.length);
			var signature:String = texture.readUTFBytes(3);
			Assert.assertEquals("Texture signature is bad", "ATF", signature);
			var n:int = _texture.length;
			_texture.position = 0;
			texture.position = 0;
			for(var i:int = 0; i < n; i++){
				var byte0:uint = _texture.readByte();
				var byte1:uint = texture.readByte();
				if(byte0 != byte1){
					Assert.fail("Texture not equals input texture");
				}
			}

			_reader.dispose();
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function findFieldInObject(object:Object, field:String):* {
			for(var p:String in object){
				if(p == field)return object[p];
			}
			return null;
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}