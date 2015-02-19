/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 14:22
 */
package com.merlinds.miracle.format.maf {
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
			for(i = 0; i < n; ++i)
			{
				a = this.animations[i];
				//test animation header
				byte = this.readByte();
				Assert.assertEquals("First flag of " + i + " animation must be DLE",
						ControlCharacters.DLE, byte);
				//read name
				length = this.readShort();
				string = this.readMultiByte(length, _charSet);
				Assert.assertEquals("Animation name is not equals", a.name, string);
				//read bounds
				Assert.assertEquals("Bounds for " + a.name + " x", a.bounds.x, this.readFloat());
				Assert.assertEquals("Bounds for " + a.name + " y", a.bounds.y, this.readFloat());
				Assert.assertEquals("Bounds for " + a.name + " width", a.bounds.width, this.readFloat());
				Assert.assertEquals("Bounds for " + a.name + " height", a.bounds.height, this.readFloat());
				Assert.assertEquals("Layer count for " + a.name, a.layers.length, this.readShort());
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
					this.addTransformation(a.name, j, layer.matrix[j]);
				//add frames
				m = layer.frames.length;
				for(j = 0; j < m; ++j)
				{
					var tf:TestFrame = layer.frames[j];
					this.addFrame(a.name, j, tf.polygonName, tf.type, tf.matrixIndex, tf.t);
				}

			}
		}

		private function prepareTestData():void {
			var layer:TestLayer;
			animations = new <TestAnimationData>[];
			var a0:TestAnimationData = new TestAnimationData("anim_0", new Rectangle(1, 2, 100, 200));
			layer = new TestLayer();
			layer.matrix[0] = this.getUniqueTransformation();
			layer.frames[0] = new TestFrame("shape0", false, 0, 1);
			a0.layers[0] = layer;
			animations[0] = a0;
			var a1:TestAnimationData = new TestAnimationData("anim_1", new Rectangle(-1, -2, -100, -200));
			layer = new TestLayer();
			layer.matrix[0] = this.getUniqueTransformation();
			layer.matrix[1] = this.getUniqueTransformation();
			layer.frames[0] = new TestFrame("shape0", true, 1, 1);
			layer.frames[1] = new TestFrame("shape1", false, 0, 2);
			a1.layers[0] = layer;
			layer = new TestLayer();
			layer.matrix[0] = this.getUniqueTransformation();
			layer.frames[0] = new TestFrame("shape2", true, 0, 3);
			a1.layers[1] = layer;
			animations[1] = a1;
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

	public function TestLayer() {
		this.frames = new <TestFrame>[];
		this.matrix = new <Transformation>[];
	}
}

class TestFrame{
	public var polygonName:String;
	public var type:Boolean;
	public var matrixIndex:int;
	public var t:Number;

	public function TestFrame(polygonName:String, type:Boolean, matrixIndex:int, t:Number) {
		this.polygonName = polygonName;
		this.type = type;
		this.matrixIndex = matrixIndex;
		this.t = t;
	}
}