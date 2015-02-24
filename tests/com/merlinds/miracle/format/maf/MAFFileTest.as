/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 14:22
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.animations.FrameType;
	import com.merlinds.miracle.format.Signatures;
	import com.merlinds.miracle.format.maf.mocks.MAFMockData;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flexunit.framework.Assert;

	public class MAFFileTest extends MAFFile{

		private var _signature:String;
		private var _charSet:String;

		private var _data:MAFMockData;
		// temporary data
		private var _polygons:Vector.<String>;
		private var _transforms:Vector.<Transformation>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFFileTest() {
			_signature = Signatures.MAF1;
			_charSet = "us-ascii";
			super(_signature, _charSet);
			_data = new MAFMockData();
			_transforms = new <Transformation>[];
			_polygons = new <String>[];
		}


		[Test]
		public function testFinalize():void {
			var matrixSize:int = 8 * 4;//8 field * 4 bytes
			var colorSize:int = 2 + 8 * 2;//color type + 8 field * 2 bytes
			var frameSize:int = 2 + 2 * 2 + 4;//frame type + 2 field * 2 bytes + 1 field * 4 bytes
			this.addHeader(matrixSize, colorSize, frameSize);

			_data.writeToFile(this);
			Assert.assertFalse("Finalized flag was set before finalization", this.finalized);
			this.finalize();
			Assert.assertTrue("Finalized flag was not set", this.finalized);
			this.testHeader(matrixSize, colorSize, frameSize);
			//test animations
			var n:int = _data.animationsLength;
			for(var i:int = 0; i < n; ++i)
			{
				Assert.assertTrue("File was ended unexpectedly", this.bytesAvailable > 0);
				var animation:AnimationHelper = this.testAnimationHeader();
				this.testPolygonNames();
				this.testTransformations();
				this.testFrames(animation);
			}
		}

//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function testHeader(matrixSize:int, colorSize:int, frameSize:int):void {
			this.position = 0;
			var signature:String = this.readMultiByte(_signature.length, _charSet);
			Assert.assertEquals("Signature", _signature, signature);
			this.position = MAFHeaderFormat.MT;
			Assert.assertEquals("MatrixSize", matrixSize, this.readShort());
			this.position = MAFHeaderFormat.CT;
			Assert.assertEquals("ColorSize", colorSize, this.readShort());
			this.position = MAFHeaderFormat.FT;
			Assert.assertEquals("frameSize", frameSize, this.readShort());
			this.position = MAFHeaderFormat.HEADER_SIZE;
		}

		private function testAnimationHeader():AnimationHelper {
			var byte:uint = this.readByte();
			Assert.assertEquals("Animation must begin with DLE byte", ControlCharacters.DLE, byte);
			var size:int = this.readShort();
			var name:String = this.readMultiByte(size, _charSet);
			var animationHelper:AnimationHelper;
			for(var n:String in _data.animations)
			{
				if(n == name)
				{
					animationHelper = _data.animations[n];
					break;
				}
			}
			var prefix:String = "Animation " + name + " ";
			Assert.assertNotNull(prefix + "was not found", animationHelper);
			//check bounds
			Assert.assertEquals(prefix + "bad bounds.x", animationHelper.bounds.x, this.readFloat());
			Assert.assertEquals(prefix + " bad bounds.y", animationHelper.bounds.y, this.readFloat());
			Assert.assertEquals(prefix + " bad bounds.width", animationHelper.bounds.width, this.readFloat());
			Assert.assertEquals(prefix + " bad bounds.height", animationHelper.bounds.height, this.readFloat());
			//check additional data
			this.collectData(animationHelper);
			Assert.assertEquals(prefix + " bad numLayers", animationHelper.numLayers, this.readShort());
			Assert.assertEquals(prefix + " bad totalFrames", animationHelper.totalFrames, this.readShort());
			Assert.assertEquals(prefix + " bad transformation count", _transforms.length, this.readShort());
			Assert.assertEquals(prefix + " bad polygons count", _polygons.length, this.readShort());
			return animationHelper;
		}

		//Tool
		private function collectData(animation:AnimationHelper):void {
			_polygons.length = 0;
			_transforms.length = 0;
			var n:int = animation.frames.length;
			for(var i:int = 0; i < n; ++i)
			{
				var index:int;
				var frame:FrameInfo = animation.frames[i];
				if(frame.isEmpty)continue;
				//save polygon if was not saved
				index = _polygons.indexOf(frame.polygonName);
				if(index < 0)_polygons.push(frame.polygonName);
				//save transformations
				index = _transforms.indexOf(frame.m0);
				if(index < 0)_transforms.push(frame.m0);
				if(frame.isMotion)
				{
					index = _transforms.indexOf(frame.m1);
					if(index < 0)_transforms.push(frame.m1);
				}
			}
		}

		private function testPolygonNames():void {
			var n:int = _polygons.length;
			for(var i:int = 0; i < n; ++i)
			{
				var expected:String = _polygons[i];
				var size:int = this.readShort();
				var name:String = this.readMultiByte(size, _charSet);
				Assert.assertEquals("Polygon name not equals", expected, name);
			}
		}

		private function testTransformations():void {
			var n:int = _transforms.length;
			for(var i:int = 0; i < n; ++i)
			{
				var t:Transformation = _transforms[i];
				this.testMatrix(t.matrix);
				this.testColor(t.color);
			}
		}

		private function testFrames(animation:AnimationHelper):void
		{
			var n:int = animation.frames.length;
			for(var i:int = 0; i < n; ++i)
			{
				var frame:FrameInfo = animation.frames[i];
				if(frame.isEmpty)
					Assert.assertEquals("Frame type is bad", FrameType.EMPTY, this.readByte());
				else
				{
					var index:int;
					Assert.assertEquals("Frame type is bad",
							frame.isMotion ? FrameType.MOTION : FrameType.STATIC, this.readByte());
					index = _polygons.indexOf( frame.polygonName );
					Assert.assertEquals("Polygon index is bad", index, this.readShort());
					index = _transforms.indexOf( frame.m0 );
					Assert.assertEquals("First matrix index is bad", index, this.readShort());
					index = frame.isMotion ? _transforms.indexOf( frame.m1 ) : -1;
					Assert.assertEquals("Second matrix index is bad", index, this.readShort());
					Assert.assertEquals("T is bad", frame.t, this.readFloat());
				}
			}
		}

		private function testMatrix(matrix:TransformMatrix):void
		{
			var value:String = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.offsetX", matrix.offsetX, value);
			value = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.offsetY", matrix.offsetY, value);
			value = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.scaleX", matrix.scaleX, value);
			value = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.scaleY", matrix.scaleY, value);
			value = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.skewX", matrix.skewX, value);
			value = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.skewY", matrix.skewY, value);
			value = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.tx", matrix.tx, value);
			value = this.readFloat().toFixed(3);
			Assert.assertEquals("Bad matrix.ty", matrix.ty, value);
		}

		private function testColor(color:Color):void
		{
			var type:uint = this.readByte();
			this.position++;
			Assert.assertEquals("Bad color.type", color.type, type);
			Assert.assertEquals("Bad color.alphaOffset", int(color.alphaOffset * 255), this.readShort());
			Assert.assertEquals("Bad color.alphaMultiplier", int(color.alphaMultiplier * 255), this.readShort());
			Assert.assertEquals("Bad color.redOffset", int(color.redOffset * 255), this.readShort());
			Assert.assertEquals("Bad color.redMultiplier", int(color.redMultiplier * 255), this.readShort());
			Assert.assertEquals("Bad color.greenOffset", int(color.greenOffset * 255), this.readShort());
			Assert.assertEquals("Bad color.greenMultiplier", int(color.greenMultiplier * 255), this.readShort());
			Assert.assertEquals("Bad color.blueOffset", int(color.blueOffset * 255), this.readShort());
			Assert.assertEquals("Bad color.blueMultiplier", int(color.blueMultiplier * 255), this.readShort());
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
