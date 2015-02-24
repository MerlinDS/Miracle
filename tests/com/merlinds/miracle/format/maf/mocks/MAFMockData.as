/**
 * User: MerlinDS
 * Date: 24.02.2015
 * Time: 18:36
 */
package com.merlinds.miracle.format.maf.mocks {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.EmptyFrameInfo;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.format.maf.MAFFile;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;

	import flash.geom.Rectangle;

	public class MAFMockData {

		private var tCount:int;
		private var _animations:Object;
		private var _animationsLength:int;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MAFMockData() {
			_animations = {};
			this.generateData();
		}

		public function writeToFile(file:MAFFile):void {
			for(var name:String in _animations)
			{
				file.addAnimation(name, _animations[name]);
				_animationsLength++;
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function generateData():void {
			var frames:Vector.<FrameInfo>;
			//anim_0
			frames = new <FrameInfo>[
				new FrameInfo("shape_0", this.getUniqueTransformation(), null, 1)
			];
			_animations["anim_0"] = new AnimationHelper("anim_0", 1, 1, frames);
			_animations["anim_0"].bounds = new Rectangle(1, 2, 10, 20);
			//anim_1
			var t:Transformation = this.getUniqueTransformation();
			frames = new <FrameInfo>[
				new FrameInfo("shape_1", this.getUniqueTransformation(), t, 0),
				new FrameInfo("shape_1", t, null, 1),
				new EmptyFrameInfo(),
				new FrameInfo("shape_2", this.getUniqueTransformation(), null, 0),
				//next layer
				new EmptyFrameInfo(),
				new FrameInfo("shape_3", this.getUniqueTransformation(), null, 0),
				new EmptyFrameInfo(),
				new EmptyFrameInfo()
			];

			_animations["anim_1"] = new AnimationHelper("anim_1", 4, 2, frames);
			_animations["anim_1"].bounds = new Rectangle(4, 5, 30, 40);
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

		public function get animations():Object {
			return _animations;
		}

		public function get animationsLength():int {
			return _animationsLength;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
