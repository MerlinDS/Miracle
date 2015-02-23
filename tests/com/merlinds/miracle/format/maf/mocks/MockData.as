/**
 * User: MerlinDS
 * Date: 23.02.2015
 * Time: 17:00
 */
package com.merlinds.miracle.format.maf.mocks {
	import com.merlinds.miracle.animations.FrameType;
	import com.merlinds.miracle.format.maf.MAFFile;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;

	import flash.geom.Rectangle;

	public class MockData {

		private var tCount:int;
		private var _file:MAFFile;
		private var _animations:Vector.<TestAnimationData>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MockData() {
			this.prepareTestData();
		}

		public function addDataToFile(file:MAFFile):void {
			_file = file;
			var i:int, n:int;
			n = this.animations.length;
			for(i = 0; i < n; ++i)
			{
				var a:TestAnimationData = this.animations[i];
				_file.addAnimation(a.name, a.bounds);
				this.addAnimation(a);
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function addAnimation(a:TestAnimationData):void {
			var i:int, j:int, n:int, m:int;
			n = a.layers.length;
			for(i = 0; i < n; ++i)
			{
				var layer:TestLayer = a.layers[i];
				m = layer.matrix.length;
				//add layer transformations
				for(j = 0; j < m; ++j)
					_file.addTransformation(a.name, i, layer.matrix[j]);
				//add frames
				m = layer.frames.length;
				for(j = 0; j < m; ++j)
				{
					var tf:TestFrame = layer.frames[j];
					_file.addFrame(a.name, i, tf.type, tf.polygonName,  tf.matrixIndex, tf.t);
				}

			}
		}

		private function prepareTestData():void {
			var layer:TestLayer;
			_animations = new <TestAnimationData>[];
			var a0:TestAnimationData = new TestAnimationData("anim_0", new Rectangle(1, 2, 100, 200));
			layer = new TestLayer();
			layer.matrix[0] = this.getUniqueTransformation();
			layer.frames[0] = new TestFrame("shape0", FrameType.MOTION, 0, 1);
			layer.polygons[0] = "shape0";
			a0.layers[0] = layer;
			_animations.push(a0);
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
			_animations.push(a1);
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

		public function get animations():Vector.<TestAnimationData> {
			return _animations;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}