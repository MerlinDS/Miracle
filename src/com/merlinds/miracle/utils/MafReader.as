/**
 * User: MerlinDS
 * Date: 18.07.2014
 * Time: 18:24
 */
package com.merlinds.miracle.utils {
	import com.merlinds.miracle.animations.Animation;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.meshes.MeshMatrix;

	import flash.utils.ByteArray;

	public class MafReader {

		private var _animations:Vector.<Animation>;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MafReader() {
		}

		public function execute(bytes:ByteArray):void {
			_animations = new <Animation>[];
			//ignore signature
			bytes.position = 4;
			var animationList:Array = bytes.readObject();
			var n:int = animationList.length;
			for(var i:int = 0; i < n; i++){
				var data:Object = animationList[i];
				//create animation holder
				var animation:Animation = new Animation( data.name, data.totalFrames,
						this.parseLayers( data.layers, data.totalFrames )
				);
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
		private function parseLayers(layers:Array, totalFrames:int):Vector.<FrameInfo> {
			var n:int = layers.length;
			var frames:Vector.<FrameInfo> = new <FrameInfo>[];
			frames.length = totalFrames * n + 1;//For deploying list from rectangular to liner
			frames.fixed = true;// Can not be more than total frames count
			for(var i:int = 0; i < n; i++){
				var j:int, m:int;
				var layer:Object = layers[i];
				//prepare list of matrix
				m = layer.meshes.length;
				for(j = 0; j < m; j++){
					layer.matrixList[j] = MeshMatrix.fromObject(layer.framesList[j]);
				}
				//fill frames list
				m = layer.frames.length;
				for(j = 0; j < m; j++){
					var frameData:Object = layer.framesList[j];
					if(frameData != null){
						var m0:MeshMatrix, m1:MeshMatrix;
						m0 = layer.matrixList[ frameData.index ];//target polygon matrix
						if(frameData.motion){
							m1 = layer.meshes[ frameData.index + 1 ];//next polygon matrix
						}
						frames[totalFrames * i + j] = new FrameInfo( frameData.polygonName, m0, m1, frameData.t );

					}else{
						frames[totalFrames * i + j] = null;//Frame is empty
					}
				}
			}
			layer.length = null;
			return frames;
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function get animations():Vector.<Animation> {
			return _animations;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
