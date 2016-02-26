/**
 * User: MerlinDS
 * Date: 18.07.2014
 * Time: 18:24
 */
package com.merlinds.miracle.utils {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.EmptyFrameInfo;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;

	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class MafReader {

		private var _animations:Vector.<AnimationHelper>;
		private var _scale:Number;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MafReader() {
		}

		public function execute(bytes:ByteArray, scale:Number):void {
			_animations = new <AnimationHelper>[];
			_scale = scale;
			//ignore signature
			bytes.position = 4;
			var animationList:Array = bytes.readObject();
			var n:int = animationList.length;
			for(var i:int = 0; i < n; i++){
				var data:Object = animationList[i];
				//create animation holder
				var animation:AnimationHelper = new AnimationHelper( data.name, data.totalFrames,
						data.layers.length, this.parseLayers( data.layers, data.totalFrames )
				);
				animation.bounds = this.parseBounds(data.bounds);
				_animations.push( animation );
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		/**
		 * Parse animation file format and create frames for miracle animation animation
		 * @param layers List of layers in file
		 * @param totalFrames Count of total frames for animation.
		 * @return List of frames of animation. Rectangular list that deployed in a linear one.
		 */
		[Inline]
		private final function parseLayers(layers:Array, totalFrames:int):Vector.<FrameInfo> {
			var n:int = layers.length;
			var frames:Vector.<FrameInfo> = new <FrameInfo>[];
			frames.length = totalFrames * n;//For deploying list from rectangular to liner
			frames.fixed = true;// Can not be more than total frames count
			//Fill frames list by emptyFrames
			var i:int = -1;
			while(++i < frames.length){
				frames[i] = EmptyFrameInfo.getConst();
			}

			for(i = 0; i < n; i++){
				var j:int, m:int;
				var layer:Object = layers[i];
				//prepare list of matrix
				m = layer.matrixList.length;
				for(j = 0; j < m; j++){
					layer.matrixList[j] = this.parseTransformation(layer.matrixList[j]);
				}
				//fill frames list
				m = layer.framesList.length;
				for(j = 0; j < m; j++){
					var frameData:Object = layer.framesList[j];
					if(frameData != null){
						var m0:Transformation, m1:Transformation;
						m0 = layer.matrixList[ frameData.index ];//target polygon matrix
						if(frameData.motion){
							m1 = layer.matrixList[ frameData.index + 1 ];//next polygon matrix
						}
						frames[totalFrames * i + j] = new FrameInfo( frameData.polygonName, m0, m1, frameData.t );

					}
				}
			}
			layers.length = 0;//delete layer list
			return frames;
		}

		//TODO generate format as byte array, not a simple object
		private final function parseTransformation(data:Object):Transformation{
			var transform:Transformation;
			 if(data != null){
				transform = new Transformation();
				transform.matrix = this.parseMatrix(data.matrix);
				transform.color = this.parseColor(data.color);
			 }
			return transform;
		}

		[Inline]
		private final function parseMatrix(data:Object):TransformMatrix {
			var meshMatrix:TransformMatrix = new TransformMatrix(
					data.offsetX * _scale, data.offsetY * _scale, data.tx * _scale, data.ty * _scale,
					data.scaleX, data.scaleY, data.skewX, data.skewY
			);
			return meshMatrix;
		}

		/**
		 * Create Color from not serialized object
		 * @param data Object that contains data about color
		 * @return Color object serialized instance
		 */
		[Inline]
		private final function parseColor(data:Object):Color {
			var color:Color = new Color(
					data.redMultiplier, data.greenMultiplier, data.blueMultiplier, data.alphaMultiplier,
					data.redOffset, data.greenOffset, data.blueOffset, data.alphaOffset
			);
			color.type = data.type;
			return color;
		}

		[Inline]
		private final function parseBounds(data:Object):Rectangle {
			return new Rectangle(data.x * _scale, data.y * _scale, data.width * _scale, data.height * _scale);
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get animations():Vector.<AnimationHelper> {
			return _animations;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
