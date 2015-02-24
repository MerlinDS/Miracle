/**
 * User: MerlinDS
 * Date: 23.02.2015
 * Time: 16:23
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.format.ReaderStatus;
	import com.merlinds.miracle.format.Signatures;
	import com.merlinds.miracle.format.maf.mocks.MAFMockData;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;

	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	public class MAFReaderTest {

		private var _charSet:String;
		private var _reader:MAFReader;
		private var _maf1:ByteArray;
		private var _mock:MAFMockData;
		//==============================================================================
		//{region							PUBLIC METHODS

		[Before]
		public function setUp():void {
			_charSet = "us-ascii";
			_reader = new MAFReader(Signatures.MAF1, 6);
			var maf:MAF1 = new MAF1();
			_mock = new MAFMockData();
			_mock.writeToFile(maf);
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
			Assert.assertEquals("Reader status must equals READY: ", ReaderStatus.READY, _reader.status);


			for(var name:String in animations)
			{
				var expected:AnimationHelper = _mock.animations[name];
				var animation:AnimationHelper = animations[name];
				var prefix:String = "Animation " + name + ": ";
				Assert.assertNotNull(prefix + "can not found this animation", expected);
				Assert.assertEquals(prefix + "numLayers", expected.numLayers, animation.numLayers);
				Assert.assertEquals(prefix + "totalFrames", expected.totalFrames, animation.totalFrames);
				//bounds
				Assert.assertEquals(prefix + "bounds.x", expected.bounds.x, animation.bounds.x);
				Assert.assertEquals(prefix + "bounds.y", expected.bounds.y, animation.bounds.y);
				Assert.assertEquals(prefix + "bounds.width", expected.bounds.width, animation.bounds.width);
				Assert.assertEquals(prefix + "bounds.height", expected.bounds.height, animation.bounds.height);
				//
				var n:int = animation.frames.length;
				for(var i:int = 0; i < n; ++i)
				{
					var frame:FrameInfo = animation.frames[i];
					var expectedFrame:FrameInfo = expected.frames[i];
					Assert.assertEquals("Frame isEmpty", expectedFrame.isEmpty, frame.isEmpty);
					Assert.assertEquals("Frame isMotion", expectedFrame.isMotion, frame.isMotion);
					Assert.assertEquals("Polygon name", expectedFrame.polygonName, frame.polygonName);
					Assert.assertEquals("T", expectedFrame.t, frame.t);
					//Check transformations
					if(!frame.isEmpty)
					{
						this.testMatrix(frame.m0.matrix, expectedFrame.m0.matrix);
						this.testColor(frame.m0.color, expectedFrame.m0.color);
						if(frame.isMotion)
						{
							this.testMatrix(frame.m1.matrix, expectedFrame.m1.matrix);
							this.testColor(frame.m1.color, expectedFrame.m1.color);
						}
					}
				}
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function testMatrix(m:TransformMatrix, e:TransformMatrix):void {
			var value:String = m.offsetX.toFixed(2);
			Assert.assertEquals("offsetX", e.offsetX, value);
			value = m.offsetY.toFixed(2);
			Assert.assertEquals("offsetY", e.offsetY, value);
			value = m.scaleX.toFixed(2);
			Assert.assertEquals("scaleX", e.scaleX, value);
			value = m.scaleY.toFixed(2);
			Assert.assertEquals("scaleY", e.scaleY, value);
			value = m.skewX.toFixed(2);
			Assert.assertEquals("skewX", e.skewX, value);
			value = m.skewY.toFixed(2);
			Assert.assertEquals("skewY", e.skewY, value);
			value = m.tx.toFixed(2);
			Assert.assertEquals("tx", e.tx, value);
			value = m.ty.toFixed(2);
			Assert.assertEquals("ty", e.ty, value);
		}

		private function testColor(c:Color, e:Color):void {
			var value:String = c.alphaMultiplier.toFixed(2);
			Assert.assertEquals("alphaMultiplier", e.alphaMultiplier, value);
			value = c.alphaOffset.toFixed(2);
			Assert.assertEquals("alphaOffset", e.alphaOffset, value);
			value = c.redMultiplier.toFixed(2);
			Assert.assertEquals("redMultiplier", e.redMultiplier, value);
			value = c.redOffset.toFixed(2);
			Assert.assertEquals("redOffset", e.redOffset, value);
			value = c.greenMultiplier.toFixed(2);
			Assert.assertEquals("greenMultiplier", e.greenMultiplier, value);
			value = c.greenOffset.toFixed(2);
			Assert.assertEquals("greenOffset", e.greenOffset, value);
			value = c.blueOffset.toFixed(2);
			Assert.assertEquals("blueOffset", e.blueOffset, value);
			value = c.blueMultiplier.toFixed(2);
			Assert.assertEquals("blueMultiplier", e.blueMultiplier, value);
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
