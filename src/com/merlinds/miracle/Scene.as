/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:36
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.animations.AnimationHelper;
	import com.merlinds.miracle.animations.FrameInfo;
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.meshes.Mesh2D;
	import com.merlinds.miracle.meshes.MeshMatrix;
	import com.merlinds.miracle.meshes.Polygon2D;
	import com.merlinds.miracle.textures.TextureHelper;
	import com.merlinds.miracle.utils.Asset;

	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;

	internal class Scene extends AbstractScene implements IScene{
		/**
		 * [x,y] + [u,v] + [tx, ty] + [scaleX, scaleY, skewX, skewY] + [r,g,b,a]
		 */
		private const VERTEX_PARAMS_LENGTH:int = 2 + 2 + 2 + 4 + 4;
		//GPU
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _vertexData:Vector.<Number>;
		private var _indexData:Vector.<uint>;
		//
		private var _vertexOffset:Number = 0;
		private var _indexOffset:Number = 0;
		private var _indexStep:Number = 0;
		private var _currentTexture:String;
		//drawing
		private var _currentMatrix:MeshMatrix = new MeshMatrix();
		private var _polygon:Polygon2D;
		//
		use namespace miracle_internal;

		public function Scene(assets:Vector.<Asset>, scale:Number = 1) {
			_vertexData = new <Number>[];
			_indexData = new <uint>[];
			super(assets, scale);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		//IScene
		public function createImage(texture:String = null, anim:String = null):MiracleImage {
			var instance:MiracleDisplayObject = this.createInstance(MiracleImage);
			instance.texture = texture;
			instance.mesh = texture;
			instance.animation = anim;
			instance.currentFrame = 0;
			instance.fps = 0;
			return instance as MiracleImage;
		}

		public function createAnimation(texture:String, animation:String, fps:int = 60):MiracleAnimation{
			var instance:MiracleDisplayObject = this.createInstance(MiracleAnimation);
			instance.texture = texture;
			instance.mesh = texture;
			instance.animation = animation;
			instance.currentFrame = 0;
			instance.fps = fps;
			return instance as MiracleAnimation;
		}

		public function createInstance(serializer:Class):MiracleDisplayObject {
			var instance:MiracleDisplayObject = new serializer();
			_displayObjects[_displayObjects.length++] = instance;
			trace("Miracle: Instance was created.");
			return instance;
		}

		public function textureInUse(texture:String):Boolean{
			var textureHelper:TextureHelper = _textures[texture];
			return textureHelper.inUse;
		}

		//IRenderer
		override public function end(present:Boolean = true):void {
			this.drawTriangles();
			if(present) {
				_context.present();
			}
		}

		override public function drawFrame(time:Number):void {
			var mesh:Mesh2D;
			var animationHelper:AnimationHelper;
			var textureHelper:TextureHelper;
			var instance:MiracleDisplayObject;
			var n:int = _displayObjects.length;
			for(var i:int = 0; i < n; i++){
				instance = _displayObjects[i];
				//instance is not ready to use
				if(instance.texture && instance.animation){

					mesh = _meshes[ instance.mesh ];
					textureHelper = _textures[ instance.texture ];
					animationHelper = _animations[ instance.animation ];
					if(mesh == null || textureHelper == null){
						throw new ArgumentError("Can not draw display object without mesh or texture");
					}

					if(!textureHelper.inUse){
						if(!textureHelper.uploading){
							//upload texture to GPU
							this.initializeInstance(instance);
						}
					}else{
						//update texture
						if(_currentTexture != instance.texture){
							if(_currentTexture != null)this.drawTriangles();
							_context.setTextureAt(0, textureHelper.texture);
							_currentTexture = instance.texture;
						}
						//reset old sizes
						instance.width = instance.height = 0;
						var m:int = animationHelper.numLayers;
						var k:int = animationHelper.totalFrames;
						for(var j:int = 0; j < m; j++){
							var index:int = k * j + instance.currentFrame;
							var frame:FrameInfo = animationHelper.frames[ index ];
							if(frame != null){
								_polygon = mesh[ frame.polygonName ];
								//draw on GPU
								this.calculateMatrix(instance.drawMatrix, frame.m0, frame.m1, frame.t);
								_currentMatrix.color = [0, 0, 0, 0.1];
								this.draw();
							}
						}
						instance.timePassed += time;
						if(instance.timePassed >= instance.frameDelta){
							instance.timePassed = 0;
							//increase frame counter for current instance
							if(++instance.currentFrame >= animationHelper.totalFrames){
								instance.currentFrame = 0;
							}
						}

						//set size //TODO: change size only if animation for this instance was changed
						instance.width = animationHelper.width;
						instance.height = animationHelper.height;
						//tell instance that it was drawn on GPU
						instance.miracle_internal::drawn();
					}

				}
			}

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS

		private function initializeInstance( instance:MiracleDisplayObject ):void {
			var mesh:Mesh2D = _meshes[instance.mesh];
			var textureHelper:TextureHelper = _textures[instance.texture];

			if(mesh == null){
				throw ArgumentError("Cannot find mesh with name " + instance.mesh);
			}

			if(textureHelper == null){
				throw ArgumentError("Cannot find texture with name " + instance.texture);
			}

			textureHelper.texture = _context.createTexture(textureHelper.width,
					textureHelper.height, textureHelper.format, false);
		}

		[Inline]
		private function drawTriangles():void {
			var n:int;
			if(_vertexData.length > 0){
				n = _vertexData.length / VERTEX_PARAMS_LENGTH;
				_vertexBuffer = _context.createVertexBuffer( n , VERTEX_PARAMS_LENGTH);
				_vertexBuffer.uploadFromVector(_vertexData, 0, n );
				n = _indexData.length;
				_indexBuffer = _context.createIndexBuffer(n);
				_indexBuffer.uploadFromVector(_indexData, 0, n);

				_context.setVertexBufferAt(0, _vertexBuffer, 0, "float2"); //x, y
				_context.setVertexBufferAt(1, _vertexBuffer, 2, "float2"); //u, v
				_context.setVertexBufferAt(2, _vertexBuffer, 4, "float2"); //tx, ty
				_context.setVertexBufferAt(3, _vertexBuffer, 6, "float4"); //scaleX, scaleY, skewX, skewY
				_context.setVertexBufferAt(4, _vertexBuffer, 10, "float4"); //R, G, B, A
				_context.drawTriangles( _indexBuffer );
			}
			_vertexOffset = 0;
			_indexOffset = 0;
			_indexStep = 0;
			//
			_vertexData.length = 0;
			_indexData.length = 0;
		}

		[Inline]
		private function draw():void {
			var i:int;
			var dataIndex:int = 0;
			var n:int = _polygon.numVertexes;
			//set vertexes
			for(i = 0; i < n; i++){
				/**** ADD VERTEX DATA *****/
				_vertexData[_vertexOffset++] = _polygon.buffer[ dataIndex++ ] + _currentMatrix.offsetX;
				_vertexData[_vertexOffset++] = _polygon.buffer[ dataIndex++ ] + _currentMatrix.offsetY;
				/**** ADD UV DATA *****/
				_vertexData[_vertexOffset++] = _polygon.buffer[ dataIndex++ ];
				_vertexData[_vertexOffset++] = _polygon.buffer[ dataIndex++ ];
				/**** ADD TRANSFORM INDEXES DATA *****/
				_vertexData[_vertexOffset++] = _currentMatrix.tx;
				_vertexData[_vertexOffset++] = _currentMatrix.ty;
				_vertexData[_vertexOffset++] = _currentMatrix.scaleX;
				_vertexData[_vertexOffset++] = _currentMatrix.scaleY;
				_vertexData[_vertexOffset++] = _currentMatrix.skewX;
				_vertexData[_vertexOffset++] = _currentMatrix.skewY;
				/**** ADD COLOR DATA *****/
				_vertexData[_vertexOffset++] = _currentMatrix.color[0];
				_vertexData[_vertexOffset++] = _currentMatrix.color[1];
				_vertexData[_vertexOffset++] = _currentMatrix.color[2];
				_vertexData[_vertexOffset++] = _currentMatrix.color[3];
			}
			/**** FILL INDEXES BUFFER *****/
			n = _polygon.indexes.length;
			for(i = 0; i < n; i++){
				_indexData[_indexOffset++] = _indexStep + _polygon.indexes[i];
			}
			_indexStep += _polygon.numVertexes;
		}

		[Inline]
		private function calculateMatrix(dm:MeshMatrix, m0:MeshMatrix, m1:MeshMatrix, t:Number):void {
			var t0:Number = 1 - t;
			_currentMatrix.offsetX = (t0 * m0.offsetX + t * m1.offsetX );
			_currentMatrix.offsetY = (t0 * m0.offsetY + t * m1.offsetY );
			_currentMatrix.tx = dm.tx + (t0 * m0.tx + t * m1.tx ) * dm.scaleX;
			_currentMatrix.ty = dm.ty + ( t0 * m0.ty + t * m1.ty ) * dm.scaleY;
			_currentMatrix.scaleX = dm.scaleX * (t0 * m0.scaleX + t * m1.scaleX);
			_currentMatrix.scaleY = dm.scaleY * (t0 * m0.scaleY + t * m1.scaleY);
			_currentMatrix.skewX = dm.skewX + (t0 * m0.skewX + t * m1.skewX );
			_currentMatrix.skewY = dm.skewY + (t0 * m0.skewY + t * m1.skewY );
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