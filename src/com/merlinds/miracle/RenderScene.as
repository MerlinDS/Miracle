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
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;
	import com.merlinds.miracle.textures.TextureHelper;

	import flash.display3D.Context3DVertexBufferFormat;

	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	internal class RenderScene extends AbstractScene{
		/**
		 * [x,y] + [u,v] + [tx, ty] + [scaleX, scaleY, skewX, skewY] + [r,g,b,a] + [multiplierR, multiplierG, multiplierB, multiplierA]
		 */
		private const VERTEX_PARAMS_LENGTH:int = 2 + 2 + 2 + 4 + 4 + 4;
		//GPU
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _verticesData:ByteArray;
		private var _indexData:ByteArray;
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

		public function RenderScene(scale:Number = 1) {
			_currentMatrix = new TransformMatrix();
			_currentColor = new Color();
			_verticesData = new ByteArray();
			_verticesData.endian = Endian.LITTLE_ENDIAN;
			_indexData = new ByteArray();
			_indexData.endian = Endian.LITTLE_ENDIAN;
			_vertexOffset = 0;
			_indexOffset = 0;
			_indexStep = 0;
			super(scale);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		//IScene
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
			var n:int = _drawableObjects.length;
			for(var i:int = 0; i < n; i++){
				//collect instance data
				instance = _drawableObjects[i];
				mesh = _meshes[instance.mesh];
				textureHelper = _textures[ mesh.textureLink ];
				animationHelper = _animations[ instance.animationId ];
				//set new bounds
				if(!instance.transformation.bounds.equals(animationHelper.bounds)){
					instance.transformation.bounds = animationHelper.bounds.clone();
				}
				//draw previous instance
				if(_currentTexture != mesh.textureLink){
					if(_currentTexture != null)this.drawTriangles();
					_context.setTextureAt(0, textureHelper.texture);
					_currentTexture = mesh.textureLink;
				}
				//==
				var m:int = animationHelper.numLayers;
				var k:int = animationHelper.totalFrames;
				for(var j:int = 0; j < m; j++){
					var index:int = k * j + instance.currentFrame;
					var frame:FrameInfo = animationHelper.frames[ index ];
					if(!frame.isEmpty){
						_polygon = mesh[ frame.polygonName ];
						//draw on GPU
						var transform:Transformation = instance.transformation;
						if(!frame.isMotion){
							this.staticMatrix(transform.matrix, frame.m0.matrix);
							this.staticColor(transform.color, frame.m0.color);
						}else{
							this.motionMatrix(transform.matrix, frame.m0.matrix, frame.m1.matrix, frame.t);
							this.motionColor(transform.color, frame.m0.color, frame.m1.color, frame.t);
						}
						this.draw();
					}
				}

				if(instance is MiracleAnimation)//only animation had timeline
					this.changeInstanceFrame(instance as MiracleAnimation, k, time);
				//tell instance that it was drawn on GPU
				instance.miracle_internal::drawn();
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		[Inline]
		private final function changeInstanceFrame(instance:MiracleAnimation, totalFrames:Number, time:Number):void {
			//calculate possibility of frame changing
			instance.timePassed += time;
			if(instance.timePassed >= instance.frameDelta){
				instance.timePassed = 0;
				//need to change frame
				if(instance.playbackDirection != 0){//stop frame changing if playback direction equals 0
					instance.currentFrame += instance.playbackDirection;
					if(instance.currentFrame == totalFrames || instance.currentFrame < 0){
						if(instance.loop){
							//switch current frame to start or end
							instance.currentFrame = instance.playbackDirection > 0 ? 0 : totalFrames - 1;
						}else{
							instance.currentFrame -= instance.playbackDirection;//return to previous frame
							instance.miracle_internal::stopPlayback();
						}
					}
				}
			}
		}

		[Inline]
		private final function drawTriangles():void {
			var n:int;
			_indexData.position = 0;
			_verticesData.position = 0;
			if(_verticesData.length > 0){
				n = (_verticesData.length >> 2)/ VERTEX_PARAMS_LENGTH;
				_vertexBuffer = _context.createVertexBuffer( n , VERTEX_PARAMS_LENGTH );
				_vertexBuffer.uploadFromByteArray(_verticesData, 0, 0, n );
				n = _indexData.length >> 1;
				_indexBuffer = _context.createIndexBuffer(n);
				_indexBuffer.uploadFromByteArray(_indexData, 0, 0, n);
				_context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //x, y
				_context.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //u, v
				_context.setVertexBufferAt(2, _vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_2); //tx, ty
				_context.setVertexBufferAt(3, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_4); //scaleX, scaleY, skewX, skewY
				_context.setVertexBufferAt(4, _vertexBuffer, 10, Context3DVertexBufferFormat.FLOAT_4); //R, G, B, A
				_context.setVertexBufferAt(5, _vertexBuffer, 14, Context3DVertexBufferFormat.FLOAT_4); //multiplierR, multiplierG, multiplierB, multiplierA
				_context.drawTriangles( _indexBuffer );

				_vertexBuffer.dispose();
				_indexBuffer.dispose();
			}
			_vertexOffset = 0;
			_indexStep = 0;
			//
			_verticesData.clear();
			_indexData.clear();
		}

		[Inline]
		private final function draw():void {
			var i:int;
			var dataIndex:int = 0;
			var n:int = _polygon.numVertices;
			//_verticesData.position = _vertexOffset;
			//set vertexes
			for(i = 0; i < n; i++){
				/**** ADD VERTEX DATA *****/
				_verticesData.writeFloat(_polygon.buffer[ dataIndex++ ] + _currentMatrix.offsetX);
				_verticesData.writeFloat(_polygon.buffer[ dataIndex++ ] + _currentMatrix.offsetY);
				/**** ADD UV DATA *****/
				_verticesData.writeFloat(_polygon.buffer[ dataIndex++ ]);
				_verticesData.writeFloat(_polygon.buffer[ dataIndex++ ]);
				/**** ADD TRANSFORM INDEXES DATA *****/
				_verticesData.writeFloat( _currentMatrix.tx );
				_verticesData.writeFloat( _currentMatrix.ty );
				_verticesData.writeFloat( _currentMatrix.scaleX );
				_verticesData.writeFloat( _currentMatrix.scaleY );
				_verticesData.writeFloat( _currentMatrix.skewX );
				_verticesData.writeFloat( _currentMatrix.skewY );
				/**** ADD COLOR OFFSET DATA *****/
				_verticesData.writeFloat( _currentColor.redOffset );
				_verticesData.writeFloat( _currentColor.greenOffset );
				_verticesData.writeFloat( _currentColor.blueOffset );
				_verticesData.writeFloat( _currentColor.alphaOffset );
				/**** ADD COLOR MULTIPLIER DATA *****/
				_verticesData.writeFloat( _currentColor.redMultiplier );
				_verticesData.writeFloat( _currentColor.greenMultiplier );
				_verticesData.writeFloat( _currentColor.blueMultiplier );
				_verticesData.writeFloat( _currentColor.alphaMultiplier );
			}
		//	_vertexOffset += VERTEX_PARAMS_LENGTH * 4;
			/**** FILL INDEXES BUFFER *****/
			n = _polygon.indexes.length;
			for(i = 0; i < n; i++){
				_indexData.writeShort( _indexStep + _polygon.indexes[i] );
			}
			_indexStep += _polygon.numVertices;
		}

		//static
		/**
		 * Calculate new matrix transformation for processed polygon
		 * @param m0 instance matrix transformation
		 * @param m1 initial matrix transformation
		 */
//		[Inline]
		private final function staticMatrix(m0:TransformMatrix, m1:TransformMatrix):void {
			/**** CALCULATE FORM TRANSFORMATIONS *****/
			_currentMatrix.offsetX = m1.offsetX;
			_currentMatrix.offsetY = m1.offsetY;
			_currentMatrix.tx = m0.tx + m1.tx * m0.scaleX;
			_currentMatrix.ty = m0.ty + m1.ty * m0.scaleY;
			_currentMatrix.scaleX = m0.scaleX * m1.scaleX;
			_currentMatrix.scaleY = m0.scaleY * m1.scaleY;
			_currentMatrix.skewX = m0.skewX + m1.skewX;
			_currentMatrix.skewY = m0.skewY + m1.skewY;
		}

		/**
		 * Calculate new color transformation for processed polygon
		 * @param c0 instance color transformation
		 * @param c1 initial color transformation
		 */
//		[Inline]
		private final function staticColor(c0:Color, c1:Color):void {
			/**** CALCULATE COLOR TRANSFORMATIONS *****/
			_currentColor.clear();//clear previous color transformation
			var different:uint = c0.type | c1.type ;
			var mask:uint = different & Color.COLOR;
			//If one of the colors has some transformation that need to calculate new c0 c0
			if(mask == Color.COLOR){
				//calculate offsets
				_currentColor.redOffset = c0.redOffset + c1.redOffset;//RED
				_currentColor.greenOffset = c0.greenOffset + c1.greenOffset;//GREEN
				_currentColor.blueOffset = c0.blueOffset + c1.blueOffset;//BLUE
				//calculate multipliers
				_currentColor.redMultiplier = c0.redMultiplier +  c1.redMultiplier;//RED
				_currentColor.greenMultiplier = c0.greenMultiplier + c1.greenMultiplier;//GREEN
				_currentColor.blueMultiplier = c0.blueMultiplier + c1.blueMultiplier;//BLUE
			}
			mask = different & Color.ALPHA;
			if(mask == Color.ALPHA){
				//calculate offsets
				_currentColor.alphaOffset = c0.alphaOffset + c1.alphaOffset;//ALPHA
				//calculate multipliers
				_currentColor.alphaMultiplier = c0.alphaMultiplier + c1.alphaMultiplier;//ALPHA

			}
			//change type
			_currentColor.type = Color.COLOR + Color.ALPHA;
		}

		//Motion
		/**
		 * Calculate new matrix transformation for processed polygon
		 * @param m0 instance matrix transformation
		 * @param m1 initial matrix transformation
		 * @param m2 terminal matrix transformation
		 * @param t Time delta for formula: matrix = m0 + ( ( 1 - t ) * m1 + t * m2 )
		 */
//		[Inline]
		private final function motionMatrix(m0:TransformMatrix, m1:TransformMatrix, m2:TransformMatrix, t:Number):void {
			var t0:Number = 1 - t;
			/**** CALCULATE FORM TRANSFORMATIONS *****/
			_currentMatrix.offsetX = (t0 * m1.offsetX + t * m2.offsetX );
			_currentMatrix.offsetY = (t0 * m1.offsetY + t * m2.offsetY );
			_currentMatrix.tx = m0.tx + (t0 * m1.tx + t * m2.tx ) * m0.scaleX;
			_currentMatrix.ty = m0.ty + ( t0 * m1.ty + t * m2.ty ) * m0.scaleY;
			_currentMatrix.scaleX = m0.scaleX * (t0 * m1.scaleX + t * m2.scaleX);
			_currentMatrix.scaleY = m0.scaleY * (t0 * m1.scaleY + t * m2.scaleY);
			_currentMatrix.skewX = m0.skewX + (t0 * m1.skewX + t * m2.skewX ) * m0.flipX;
			_currentMatrix.skewY = m0.skewY + (t0 * m1.skewY + t * m2.skewY ) * m0.flipX;
		}

		/**
		 * Calculate new color transformation for processed polygon
		 * @param c0 instance color transformation
		 * @param c1 initial color transformation
		 * @param c2 terminal color transformation
		 * @param t Time delta for formula: color = c0 + ( ( 1 - t ) * c1 + t * c2 )
		 */
//		[Inline]
		private final function motionColor(c0:Color, c1:Color, c2:Color, t:Number):void {
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