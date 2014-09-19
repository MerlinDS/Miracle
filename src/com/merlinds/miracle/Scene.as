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
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.textures.TextureHelper;
	import com.merlinds.miracle.utils.Asset;

	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;

	internal class Scene extends AbstractScene implements IScene{
		/**
		 * [x,y] + [u,v] + [tx, ty] + [scaleX, scaleY, skewX, skewY] + [r,g,b,a] + [multiplierR, multiplierG, multiplierB, multiplierA]
		 */
		private const VERTEX_PARAMS_LENGTH:int = 2 + 2 + 2 + 4 + 4 + 4;
		//GPU
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _vertexData:Vector.<Number>;
		private var _indexData:Vector.<uint>;
		//
		private var _vertexOffset:Number;
		private var _indexOffset:Number;
		private var _indexStep:Number;
		//drawing
		private var _polygon:Polygon2D;
		private var _currentMatrix:TransformMatrix;
		private var _currentColor:Color;
		private var _currentTexture:String;
		//
		use namespace miracle_internal;

		public function Scene(assets:Vector.<Asset>, scale:Number = 1) {
			_currentMatrix = new TransformMatrix();
			_currentColor = new Color();
			_vertexData = new <Number>[];
			_indexData = new <uint>[];
			_vertexOffset = 0;
			_indexOffset = 0;
			_indexStep = 0;
			super(assets, scale);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		//IScene
		public function createImage(mesh:String = null, animation:String = null):MiracleImage {
			var instance:MiracleDisplayObject = this.createInstance(MiracleImage);
			instance.mesh = mesh;
			instance.animation = animation;
			instance.currentFrame = 0;
			instance.fps = 0;
			return instance as MiracleImage;
		}

		public function createAnimation(mesh:String, animation:String, fps:int = 60):MiracleAnimation{
			var instance:MiracleDisplayObject = this.createInstance(MiracleAnimation);
			instance.mesh = mesh;
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
				if(instance.mesh != null && instance.animation != null){

					mesh = _meshes[ instance.mesh ];
					textureHelper = _textures[ mesh.textureLink ];
					animationHelper = _animations[ instance.mesh + "." + instance.animation ];
					//set new bounds
					if(!instance.transformation.bounds.equals(animationHelper.bounds)){
						instance.transformation.bounds = animationHelper.bounds.clone();
					}

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
						if(_currentTexture != mesh.textureLink){
							if(_currentTexture != null)this.drawTriangles();
							_context.setTextureAt(0, textureHelper.texture);
							_currentTexture = mesh.textureLink;
						}
						//reset old sizes
						var m:int = animationHelper.numLayers;
						var k:int = animationHelper.totalFrames;
						for(var j:int = 0; j < m; j++){
							var index:int = k * j + instance.currentFrame;
							var frame:FrameInfo = animationHelper.frames[ index ];
							if(frame != null){
								_polygon = mesh[ frame.polygonName ];
								//draw on GPU
								var transform:Transformation = instance.transformation;
								this.calculateMatrix(transform.matrix, frame.m0.matrix, frame.m1.matrix, frame.t);
								this.calculateColor(transform.color, frame.m0.color, frame.m1.color, frame.t);
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
			var textureHelper:TextureHelper = _textures[mesh.textureLink];

			if(mesh == null){
				throw ArgumentError("Cannot find mesh with name " + instance.mesh);
			}

			if(textureHelper == null){
				throw ArgumentError("Cannot find texture with name " + mesh.textureLink);
			}

			textureHelper.texture = _context.createTexture(textureHelper.width,
					textureHelper.height, textureHelper.format, false);
		}

		[Inline]
		private final function drawTriangles():void {
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
				_context.setVertexBufferAt(5, _vertexBuffer, 14, "float4"); //multiplierR, multiplierG, multiplierB, multiplierA
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
		private final function draw():void {
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
				/**** ADD COLOR OFFSET DATA *****/
				_vertexData[_vertexOffset++] = _currentColor.redOffset;
				_vertexData[_vertexOffset++] = _currentColor.greenOffset;
				_vertexData[_vertexOffset++] = _currentColor.blueOffset;
				_vertexData[_vertexOffset++] = _currentColor.alphaOffset;
				/**** ADD COLOR MULTIPLIER DATA *****/
				_vertexData[_vertexOffset++] = _currentColor.redMultiplier;
				_vertexData[_vertexOffset++] = _currentColor.greenMultiplier;
				_vertexData[_vertexOffset++] = _currentColor.blueMultiplier;
				_vertexData[_vertexOffset++] = _currentColor.alphaMultiplier;
			}
			/**** FILL INDEXES BUFFER *****/
			n = _polygon.indexes.length;
			for(i = 0; i < n; i++){
				_indexData[_indexOffset++] = _indexStep + _polygon.indexes[i];
			}
			_indexStep += _polygon.numVertexes;
		}

		/**
		 * Calculate new matrix transformation for processed polygon
		 * @param m0 instance matrix transformation
		 * @param m1 initial matrix transformation
		 * @param m2 terminal matrix transformation
		 * @param t Time delta for formula: matrix = m0 + ( ( 1 - t ) * m1 + t * m2 )
		 */
		[Inline]
		private final function calculateMatrix(m0:TransformMatrix, m1:TransformMatrix, m2:TransformMatrix, t:Number):void {
			var t0:Number = 1 - t;
			/**** CALCULATE FORM TRANSFORMATIONS *****/
			_currentMatrix.offsetX = (t0 * m1.offsetX + t * m2.offsetX );
			_currentMatrix.offsetY = (t0 * m1.offsetY + t * m2.offsetY );
			_currentMatrix.tx = m0.tx + (t0 * m1.tx + t * m2.tx ) * m0.scaleX;
			_currentMatrix.ty = m0.ty + ( t0 * m1.ty + t * m2.ty ) * m0.scaleY;
			_currentMatrix.scaleX = m0.scaleX * (t0 * m1.scaleX + t * m2.scaleX);
			_currentMatrix.scaleY = m0.scaleY * (t0 * m1.scaleY + t * m2.scaleY);
			_currentMatrix.skewX = m0.skewX + (t0 * m1.skewX + t * m2.skewX );
			_currentMatrix.skewY = m0.skewY + (t0 * m1.skewY + t * m2.skewY );
		}

		/**
		 * Calculate new color transformation for processed polygon
		 * @param c0 instance color transformation
		 * @param c1 initial color transformation
		 * @param c2 terminal color transformation
		 * @param t Time delta for formula: color = c0 + ( ( 1 - t ) * c1 + t * c2 )
		 */
		[Inline]
		private final function calculateColor(c0:Color, c1:Color, c2:Color, t:Number):void {
			/**** CALCULATE COLOR TRANSFORMATIONS *****/
			_currentColor.clear();//clear previous color transformation
			var t0:Number = 1 - t;
			var different:uint = c0.type | c1.type | c2.type;
			var mask:uint = different & Color.COLOR;
			//If one of the colors has some transformation that need to calculate new c0 c0
			if(mask == Color.COLOR){
				//calculate offsets
				_currentColor.redOffset = c0.redOffset +
						(t0 * c1.redOffset + t * c2.redOffset);//RED
				_currentColor.greenOffset = c0.greenOffset +
						(t0 * c1.greenOffset + t * c2.greenOffset);//GREEN
				_currentColor.blueOffset = c0.blueOffset +
						(t0 * c1.blueOffset + t * c2.blueOffset);//BLUE
				//calculate multipliers
				_currentColor.redMultiplier = c0.redMultiplier +
						(t0 * c1.redMultiplier + t * c2.redMultiplier);//RED
				_currentColor.greenMultiplier = c0.greenMultiplier +
						(t0 * c1.greenMultiplier + t * c2.greenMultiplier);//GREEN
				_currentColor.blueMultiplier = c0.blueMultiplier +
						(t0 * c1.blueMultiplier + t * c2.blueMultiplier);//BLUE
			}
			mask = different & Color.ALPHA;
			if(mask == Color.ALPHA){
				//calculate offsets
				_currentColor.alphaOffset = c0.alphaOffset +
						(t0 * c1.alphaOffset + t * c2.alphaOffset);//ALPHA
				//calculate multipliers
				_currentColor.alphaMultiplier = c0.alphaMultiplier +
						(t0 * c1.alphaMultiplier + t * c2.alphaMultiplier);//ALPHA

			}
			//change type
			_currentColor.type = Color.COLOR + Color.ALPHA;
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