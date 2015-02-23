/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 14:22
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.FrameType;
	import com.merlinds.miracle.format.Signatures;
	import com.merlinds.miracle.format.maf.mocks.MockData;
	import com.merlinds.miracle.format.maf.mocks.TestAnimationData;
	import com.merlinds.miracle.format.maf.mocks.TestFrame;
	import com.merlinds.miracle.format.maf.mocks.TestLayer;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flash.geom.Rectangle;

	import flexunit.framework.Assert;

	public class MAFFileTest extends MAFFile{

		private var _signature:String;
		private var _charSet:String;

		private var animations:Vector.<TestAnimationData>;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFFileTest() {
			_signature = Signatures.MAF1;
			_charSet = "us-ascii";
			super(_signature, _charSet);
			this.animations = new MockData().animations;
		}
		//errors
		[Test(expects="flash.errors.IllegalOperationError")]
		public function testHeaderSizesError():void {
			this.finalize();
		}

		[Test(expects="flash.errors.IllegalOperationError")]
		public function testHeaderAnimationError():void {
			this.addHeader(2, 2, 1);
			this.finalize();
		}

		[Test(expects="ArgumentError")]
		public function testFrameAddingError():void {
			this.addHeader(8*4, 2+8*2, 10);
			this.addFrame("error", 0, FrameType.EMPTY, null, 0, 0);
		}

		[Test(expects="ArgumentError")]
		public function testTransformationAddingError():void {
			this.addHeader(8*4, 2+8*2, 10);
			this.addTransformation("error", 0, null);
		}

		[Test(expects="ArgumentError")]
		public function testNullTransformationAddingError():void {
			this.addHeader(8*4, 2+8*2, 10);
			this.addAnimation("error", new Rectangle());
			var t:Transformation = new Transformation();
			this.addTransformation("error", 0, t);
		}

		//normal
		[Test]
		public function testNormalFinalization():void {
			var matrixSize:int = 8 * 4;//8 field * 4 bytes
			var colorSize:int = 2 + 8 * 2;//color type + 8 field * 2 bytes
			var frameSize:int = 2 + 2 * 2 + 4;//frame type + 2 field * 2 bytes + 1 field * 4 bytes
			this.addHeader(matrixSize, colorSize, frameSize);
			//add data to file
			var i:int, n:int;
			n = this.animations.length;
			for(i = 0; i < n; ++i)
			{
				var a:TestAnimationData = this.animations[i];
				this.addAnimation(a.name, a.bounds);
				this.addDataToFile(a);
			}
			//assert file
			Assert.assertFalse("Finalized flag was set before finalization", this.finalized);
			this.finalize();
			Assert.assertTrue("Finalized flag was not set", this.finalized);
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
			//test data
			var byte:uint;
			var length:uint;
			var string:String;
			var j:int, m:int, k:int, o:int;
			for(i = 0; i < n; ++i)
			{
				//test animation header
				byte = this.readByte();
				Assert.assertEquals("First flag of " + i + " animation must be DLE",
						ControlCharacters.DLE, byte);
				//read name
				length = this.readShort();
				string = this.readMultiByte(length, _charSet);
				//find animation
				for(j = 0; j < n; ++j)
				{
					a = this.animations[j];
					if(a.name == string)break;
					a = null;
				}
				Assert.assertNotNull("Can not found animation " + string, a);
				//read bounds
				Assert.assertEquals("Bounds for " + a.name + " x", a.bounds.x, this.readFloat());
				Assert.assertEquals("Bounds for " + a.name + " y", a.bounds.y, this.readFloat());
				Assert.assertEquals("Bounds for " + a.name + " width", a.bounds.width, this.readFloat());
				Assert.assertEquals("Bounds for " + a.name + " height", a.bounds.height, this.readFloat());
				Assert.assertEquals("Layer count for " + a.name, a.layers.length, this.readShort());

				m = a.layers.length;
				for(j = 0; j < m; ++j)
				{
					var layer:TestLayer = a.layers[j];
					byte = this.readByte();
					Assert.assertEquals("First flag of layer " + j +
							" animation of animation " + a.name + " must be GS", ControlCharacters.GS, byte);
					//length
					Assert.assertEquals("Transformation length", layer.matrix.length, this.readShort());
					Assert.assertEquals("Frames length", layer.frames.length, this.readShort());
					//polygon names
					o = layer.polygons.length;
					for(k = 0; k < o; ++k)
					{
						length = this.readShort();
						string = this.readMultiByte(length, _charSet);
						Assert.assertEquals("Polygon", layer.polygons[k], string);
					}
					byte = this.readByte();
					Assert.assertEquals("First second layer " + j +
					" animation of animation " + a.name + " must be RS", ControlCharacters.RS, byte);
					//check transformations
					o = layer.matrix.length;
					for(k = 0; k < o; ++k)
					{
						var t:Transformation = layer.matrix[k];
						//TODO FIX PROBLEMS WITH FLOAT
						//check transformation matrix
						Assert.assertEquals("offsetX", t.matrix.offsetX, this.readFloat());
						Assert.assertEquals("offsetY", t.matrix.offsetY, this.readFloat());
						Assert.assertEquals("scaleX", t.matrix.scaleX, this.readFloat().toFixed(3));
						Assert.assertEquals("scaleY", t.matrix.scaleY, this.readFloat().toFixed(3));
						Assert.assertEquals("skewX", t.matrix.skewX, this.readFloat().toFixed(3));
						Assert.assertEquals("skewY", t.matrix.skewY, this.readFloat().toFixed(3));
						Assert.assertEquals("tx", t.matrix.tx, this.readFloat());
						Assert.assertEquals("ty", t.matrix.ty, this.readFloat());
						//check color
						Assert.assertEquals("type", t.color.type, this.readBoolean());
						this.position++;
						Assert.assertEquals("alphaOffset", t.color.alphaOffset, (this.readShort() / 255).toFixed(2));
						Assert.assertEquals("alphaMultiplier", t.color.alphaMultiplier, (this.readShort() / 255).toFixed(2));
						Assert.assertEquals("redOffset", t.color.redOffset, (this.readShort() / 255).toFixed(2));
						Assert.assertEquals("redMultiplier", t.color.redMultiplier, (this.readShort() / 255).toFixed(2));
						Assert.assertEquals("greenOffset", t.color.greenOffset, (this.readShort() / 255).toFixed(2));
						Assert.assertEquals("greenMultiplier", t.color.greenMultiplier, (this.readShort() / 255).toFixed(2));
						Assert.assertEquals("blueOffset", t.color.blueOffset, (this.readShort() / 255).toFixed(2));
						Assert.assertEquals("blueMultiplier", t.color.blueMultiplier, (this.readShort() / 255).toFixed(2));
					}
					//check frames
					o = layer.frames.length;
					for(k = 0; k < o; ++k)
					{
						var f:TestFrame = layer.frames[k];
						Assert.assertEquals("Frame type", f.type, this.readByte());
						if(f.type != FrameType.EMPTY)
						{
							var pIndex:int = layer.polygons.indexOf(f.polygonName);
							Assert.assertEquals("Polygon index", pIndex, this.readShort());
							Assert.assertEquals("Transform index", f.matrixIndex, this.readShort());
							Assert.assertEquals("Time", f.t, this.readFloat().toFixed(2));
						}
					}
				}
			}

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function addDataToFile(a:TestAnimationData):void {
			var i:int, j:int, n:int, m:int;
			n = a.layers.length;
			for(i = 0; i < n; ++i)
			{
				var layer:TestLayer = a.layers[i];
				m = layer.matrix.length;
				//add layer transformations
				for(j = 0; j < m; ++j)
					this.addTransformation(a.name, i, layer.matrix[j]);
				//add frames
				m = layer.frames.length;
				for(j = 0; j < m; ++j)
				{
					var tf:TestFrame = layer.frames[j];
					this.addFrame(a.name, i, tf.type, tf.polygonName,  tf.matrixIndex, tf.t);
				}

			}
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
