/**
 * User: MerlinDS
 * Date: 07.02.2015
 * Time: 10:03
 */
package com.merlinds.miracle.formatreaders {
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;

	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	public class MiracleTextureFormatReaderTest {

		private var _charSet:String;
		private var _reader:MiracleTextureFormatReader;
		private var _fileBytes:ByteArray;
		private var _textureSize:int;

		private var _animations:Vector.<AnimationsData>;
		//==============================================================================
		//{region							PUBLIC METHODS
		[Before]
		public function setUp():void {
			var i:int, n:int;
			_charSet = "us-ascii";
			_textureSize = 4000;
			_animations = new <AnimationsData>[
					new AnimationsData("ball", [new AnimationPart("ball_image")]),
					new AnimationsData("shapes", [new AnimationPart("circle"), new AnimationPart("rect")])
			];
			var atf:FakeATFFile = new FakeATFFile(_textureSize);
			var file:TestMTF1File1 = new TestMTF1File1(_charSet);
			file.writeMTF1Header();
			n = 0;
			for(i = 0; i < _animations.length; i++){
				var animationData:AnimationsData = _animations[i];
				file.writeAnimationName(animationData.name);
				for(var j:int = 0; j < animationData.parts.length; j++){
					var animationPart:AnimationPart = animationData.parts[i];
					file.writeAnimationPartName(animationPart.name);
					file.writeAnimationSizes(animationPart.points, animationPart.indexes);
					n++;
				}
			}
			file.writeDataEscape();

			for(i = 0; i < n; i++){
				file.writeFloatArray(0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0);
				file.writeFloatArray(0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0);
				file.writeShortArray(0, 1, 2, 3, 4, 5);
			}

			file.writeDataEscape();
			file.writeBytes(atf, 0, atf.length);

			_fileBytes = file;
			_reader = new MiracleTextureFormatReader(Signatures.MTF1, 256);
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

		[Test]
		public function testRead():void {
			var meshes:Object = {};
			var texture:ByteArray = new ByteArray();
			Assert.assertEquals("Reader was not set to read yet", ReaderStatus.WAIT, _reader.status);
			_reader.read(_fileBytes, meshes, texture);
			Assert.assertTrue("Signature must be valid", _reader.isValidSignature);
			Assert.assertEquals("Reader status must equals PROCESSING", ReaderStatus.PROCESSING, _reader.status);
			while(_reader.status == ReaderStatus.PROCESSING){
				_reader.readingStep();
			}
			Assert.assertEquals("Reader status must equals READY", ReaderStatus.READY, _reader.status);
			var buffer:Vector.<Number> = new <Number>[0,1,0,1,2,3,2,3,4,5,4,5,6,7,6,7];
			var indexes:Vector.<int> = new <int>[0,1,2,3,4,5];
			var i:int;
			for(i = 0; i < _animations.length; i++){
				var animationData:AnimationsData = _animations[i];
				var mesh:Mesh2D = this.findFieldInObject(meshes, animationData.name);
				Assert.assertNotNull("Mesh " + animationData.name + " was not found in output", mesh);
				for(var j:int = 0; j < animationData.parts.length; j++){
					var animationPart:AnimationPart = animationData.parts[i];
					var polygon:Polygon2D = this.findFieldInObject(mesh, animationPart.name);
					Assert.assertNotNull("Polygon " + animationPart.name + " was not found in mesh", polygon);
					Assert.assertContained("Buffer is bad", buffer, polygon.buffer);
					Assert.assertContained("Indexes is bad", indexes, polygon.indexes);
				}
			}

			Assert.assertNotNull("Texture was not destructed", texture);
			Assert.assertEquals("Texture size is bad", _textureSize, texture.length);
			var signature:String = texture.readUTFBytes(3);
			Assert.assertEquals("Texture signature is bad", "ATF", signature);
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
class AnimationsData{
	public var name:String;
	public var parts:Vector.<AnimationPart>;


	public function AnimationsData(name:String, parts:Array) {
		this.name = name;
		this.parts = Vector.<AnimationPart>(parts);
	}
}

class AnimationPart{
	public var name:String;
	public var points:int;
	public var indexes:int;


	public function AnimationPart(name:String, points:int = 4, indexes:int = 6) {
		this.name = name;
		this.points = points;
		this.indexes = indexes;
	}
}