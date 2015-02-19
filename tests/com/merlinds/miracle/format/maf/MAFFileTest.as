/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 14:22
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.animations.FrameType;
	import com.merlinds.miracle.format.Signatures;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.utils.ControlCharacters;

	import flash.geom.Rectangle;

	import flexunit.framework.Assert;

	public class MAFFileTest extends MAFFile{

		private var tCount:int;

		private var _signature:String;
		private var _charSet:String;

		private var animations:Vector.<TestAnimationData>;

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFFileTest() {
			_signature = Signatures.MAF1;
			_charSet = "us-ascii";
			super(_signature, _charSet);
			this.prepareTestData();
		}


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

		private function prepareTestData():void {
			var layer:TestLayer;
			animations = new <TestAnimationData>[];
			var a0:TestAnimationData = new TestAnimationData("anim_0", new Rectangle(1, 2, 100, 200));
			layer = new TestLayer();
			layer.matrix[0] = this.getUniqueTransformation();
			layer.frames[0] = new TestFrame("shape0", FrameType.MOTION, 0, 1);
			layer.polygons[0] = "shape0";
			a0.layers[0] = layer;
			animations.push(a0);
			var a1:TestAnimationData = new TestAnimationData("anim_1", new Rectangle(-1, -2, -100, -200));
			layer = new TestLayer();
			layer.matrix[0] = this.getUniqueTransformation();
			layer.matrix[1] = this.getUniqueTransformation();
			layer.frames[0] = new TestFrame("shape0", FrameType.MOTION, 1, 1);
			layer.frames[1] = new TestFrame(null, FrameType.EMPTY, 0, 0);
			layer.frames[2] = new TestFrame("shape1", FrameType.MOTION, 0, 2);
			layer.polygons[0] = "shape0";
			layer.polygons[1] = "shape1";
			a1.layers[0] = layer;
			layer = new TestLayer();
			layer.matrix[0] = this.getUniqueTransformation();
			layer.frames[0] = new TestFrame("shape2", FrameType.STATIC, 0, 3);
			layer.polygons[0] = "shape2";
			a1.layers[1] = layer;
			animations.push(a1);
		}

		private function getUniqueTransformation():Transformation {
			return new Transformation(
					new TransformMatrix(tCount + 1, tCount + 2, tCount + 3, tCount + 4,
							tCount + 0.5, tCount + 0.6, tCount + 0.7, tCount + 0.8),
					new Color(tCount + 0.1, tCount + 0.2, tCount + 0.3,
							tCount + 0.4, tCount + 0.5, tCount + 0.6, tCount + 0.7, tCount + 0.8)
			);
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

import com.merlinds.miracle.geom.Transformation;

import flash.geom.Rectangle;

class TestAnimationData{
	public var name:String;
	public var bounds:Rectangle;
	public var layers:Vector.<TestLayer>;


	public function TestAnimationData(name:String, bouds:Rectangle) {
		this.name = name;
		this.bounds = bouds;
		this.layers = new <TestLayer>[];
	}
}
class TestLayer{
	public var frames:Vector.<TestFrame>;
	public var matrix:Vector.<Transformation>;
	public var polygons:Vector.<String>;

	public function TestLayer() {
		this.frames = new <TestFrame>[];
		this.matrix = new <Transformation>[];
		this.polygons = new <String>[];
	}
}

class TestFrame{
	public var polygonName:String;
	public var type:uint;
	public var matrixIndex:int;
	public var t:Number;

	public function TestFrame(polygonName:String, type:uint, matrixIndex:int, t:Number) {
		this.polygonName = polygonName;
		this.type = type;
		this.matrixIndex = matrixIndex;
		this.t = t;
	}
}