/**
 * User: MerlinDS
 * Date: 25.08.2014
 * Time: 16:15
 */
package com.merlinds.miracle.meshes {
	/**
	 * Object for animation format.
	 * Contains animation parameters, all transformations for meshes.
	 */
	public class Animation {

		/**
		 * Name of the animation.
		 * WARNING: Can be removed
		 */
		public var name:String;
		/** Total count of frames in animation **/
		public var totalFrames:int;
		/** Layers on the animation. **/
		public var layers:Vector.<Layer>;

		//==============================================================================
		//{region							PUBLIC METHODS
		/**
		 * Constructor
		 * @param name Animation name
		 * @param totalFrames Total count of frames. At least 1
		 *
		 * @throws ArgumentError if Total count of frames will be less than one
		 */
		public function Animation(name:String, totalFrames:int = 1) {
			this.name = name;
			this.totalFrames = totalFrames;
			if(this.totalFrames < 1){
				throw new ArgumentError("Must be at least one frame for animation!");
			}
		}

		/**
		 * Calculate transformations of polygons for specified frame
		 * @param frameIndex Frame index for which calculation will be made
		 * @param mesh Mesh for calculation
		 *
		 * @throws ArgumentError if frame index will be less that 0 or more than total frames count
		 * @throws ArgumentError when mesh is null
		 */
		public function calculateFrame(frameIndex:int, mesh:Mesh2D):void {
			if(frameIndex < 0 || frameIndex >= totalFrames){
				throw new ArgumentError("Frame index can not be less " +
						"than 0 or bigger than total frames count!");
			}
			if(mesh == null){
				throw new ArgumentError("Mesh can not null");
			}
			//TODO: Now it change mesh data. Need to change only draw data that will be added to displayObject instance
			//may be if will be moved to scene
			var n:int = this.layers.length;
			for(var i:int = 0; i < n; i++){
				var layer:Layer = this.layers[i];
				//get frame description
				var frame:Frame = layer.frames[ frameIndex ];
				if(frame.matrixIndex >= 0){//matrix exist, start calculation
					var polygon:MeshMatrix;// = mesh[frame.polygonName];
					var m0:MeshMatrix = layer.transformations[ frame.matrixIndex ];//get animation mesh by index
					var m1:MeshMatrix = frame.animationType == Frame.TWEEN ?
							layer.transformations[ frame.matrixIndex + 1 ]: null;
					this.appendAnimation(polygon, m0, m1, frame.t);
				}
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function appendAnimation(polygon:MeshMatrix, m0:MeshMatrix, m1:MeshMatrix = null, t:int = 0):void{
			if(m1 == null){
				m1 = new MeshMatrix(0, 0, 0, 0, 0, 0, 0, 0);
				t = 0;
			}
			var t0:Number = 1 - t;
			polygon.tx += t0 * m0.tx + t * m1.tx;
			polygon.ty += t0 * m0.ty + t * m1.ty;
			//TODO: calculate other parameters
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
