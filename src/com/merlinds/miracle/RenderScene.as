/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:36
 */
package com.merlinds.miracle
{

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
	import com.merlinds.miracle.utils.ContextDisposeState;

	import flash.display.BitmapData;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	internal class RenderScene extends AbstractScene
	{
		//
		private static  const XY:int = 2;
		/** [u,v] */
		private static  const UV:int = 2;
		/** [tx, ty] */
		private static  const OFFSET:int = 4;
		/** [scaleX, scaleY, skewX, skewY] */
		private static  const TRANSFORM:int = 4;
		/** [r,g,b,a] **/
		private static  const COLOR:int = 4;
		/** [multiplierR, multiplierG, multiplierB, multiplierA] **/
		private static  const CMULT:int = 4;

		private static  const VERTEX_PARAMS_LENGTH:int = XY + UV + OFFSET + TRANSFORM + COLOR + CMULT;

		/** positions in byte array **/
		private static const FLOAT_SIZE:int = 4;
		private static  const TRANSFORM_SIZE:int = (OFFSET + TRANSFORM) * FLOAT_SIZE;
		private static  const COLOR_SIZE:int = (COLOR + CMULT) * FLOAT_SIZE;
		private static  const MATRIX_SIZE:int = TRANSFORM_SIZE + COLOR_SIZE;
		/** color offsets **/
		private static  const MULTIPLIER_OFFSET:int = TRANSFORM_SIZE + COLOR * FLOAT_SIZE;
		private static  const ALPHA_OFFSET:int = MULTIPLIER_OFFSET - FLOAT_SIZE;//- Alpha
		private static  const ALPHA_MULTIPLIER_OFFSET:int = MATRIX_SIZE - FLOAT_SIZE;//- Alpha multiplier

		//Abstract scene
		private static  const DRAW_CUTTER:int = 8192;
		private static  const DATA_CLEANER:int = DRAW_CUTTER * 2;

		//GPU
		private var _verticesDataLength:int;
		private var _indexData:ByteArray;
		private var _indexDataLength:int;
		private var _indexStep:Number;
		private var _fixFactor:Number;
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _verticesData:ByteArray;
		//drawing
		private var _polygon:Polygon2D;
		private var _currentMatrix:ByteArray;
		private var _currentTexture:String;
		private var _clearMatrix:ByteArray;
		//
		//current instance parameters
		private var _iMesh:Mesh2D;
		private var _iAnimationHelper:AnimationHelper;
		private var _iTextureHelper:TextureHelper;
		private var _instance:MiracleDisplayObject;
		//
		use namespace miracle_internal;

		public function RenderScene(scale:Number = 1)
		{
			_currentMatrix = new ByteArray();
			_currentMatrix.endian = Endian.LITTLE_ENDIAN;
			_clearMatrix = new ByteArray();
			_clearMatrix.endian = Endian.LITTLE_ENDIAN;
			while (_clearMatrix.length < MATRIX_SIZE)_clearMatrix.writeByte(0);

			_verticesData = new ByteArray();
			_verticesData.endian = Endian.LITTLE_ENDIAN;
			_indexData = new ByteArray();
			_indexData.endian = Endian.LITTLE_ENDIAN;
			_indexStep = 0;
			_fixFactor = 0.9;
			super(scale);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		//IScene
		//IRenderer
		override protected function end(present:Boolean = true):void
		{
			this.drawTriangles();
			if(_verticesData.length > DATA_CLEANER)
			{
				_verticesData.clear();
				_indexData.clear();
			}
			if (present)
			{
				_context.present();
			}
		}

		override final protected function enterFrameHandler(event:Event = null):void
		{
			if (_context != null && _context.driverInfo != ContextDisposeState.DISPOSED)
			{
				var now:Number = new Date().time;
//				var fixFactor:Number = _timer.frameRate / 60;
				/*_passedTime = now - _lastFrameTimestamp;
				_passedTime *= (1 - fixFactor) * 0.7 + fixFactor;*/
				_passedTime = 1000 / _timer.frameRate;
				_lastFrameTimestamp = now;
				this.prepareFrames();
				_context.clear(0.8, 0.8, 0.8, 1);
				//DRAW SCENE
				var frame:FrameInfo;
				var transform:Transformation;
				var index:int, m:int, k:int;
				var n:int = _drawableObjects.length;
				for (var i:int = 0; i < n; i++)
				{
					//collect instance data
					_instance = _drawableObjects[i];
					this.collectInstanceData();
					_instance.transformation.bounds.updateBy(_iAnimationHelper.bounds);
					//switch textures
					if (_currentTexture != _iMesh.textureLink)
					{
						//Finalize textures
						if (_currentTexture != null)this.drawTriangles();
						_context.setTextureAt(0, _iTextureHelper.texture);
						_currentTexture = _iMesh.textureLink;
					}
					else if (_verticesDataLength > DRAW_CUTTER)
						this.drawTriangles();//execute drawTriangles if vertices buffer to large
					//draw instance
					m = _iAnimationHelper.numLayers;
					k = _iAnimationHelper.totalFrames;
					for (var j:int = 0; j < m; j++)
					{
						index = k * j + _instance.currentFrame;
						//collect frame data by index
						frame = _iAnimationHelper.frames[index];
						if (frame.isEmpty)continue;
						//frame not empty, calculate pivots data and draw
						_polygon = _iMesh[frame.polygonName];
						transform = _instance.transformation;
						this.clearMatrix();
						//collect data
						if (!frame.isMotion)
						{
							this.staticMatrix(transform.matrix, frame.m0.matrix);
							this.staticColor(transform.color, frame.m0.color);
						}
						else
						{
							this.motionMatrix(transform.matrix, frame.m0.matrix, frame.m1.matrix, frame.t);
							this.motionColor(transform.color, frame.m0.color, frame.m1.color, frame.t);
						}
						//draw frame
						this.draw();
					}

					if (_instance.isAnimated)//only animation had timeline
						this.changeInstanceFrame();
					//tell instance that it was drawn on GPU
					_instance.miracle_internal::drawn();
				}
				//END OF SCENE DRAW
				if (_drawScreenShot)
				{
					this.drawTriangles();
					this.drawScreenShot();
				}
				this.end();
			}
			else
			{
				//stop drawing
				_timer.removeEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
				if (_lostContextCallback is Function)
					_lostContextCallback.apply(this);
			}
		}

		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS

		[Inline]
		private final function clearMatrix():void
		{
			//clear matrix
			_clearMatrix.position = 0;
			_currentMatrix.position = 0;
			_currentMatrix.writeBytes(_clearMatrix, 0, _clearMatrix.length);
			_currentMatrix.position = 0;
			//collect data
		}

		//draw frame methods
		[Inline]
		private final function collectInstanceData():void
		{
			_iMesh = _meshes[_instance.mesh];
			_iTextureHelper = _textures[_iMesh.textureLink];
			_iAnimationHelper = _animations[_instance.animationId];
		}

		[Inline]
		private final function changeInstanceFrame():void
		{
			var instance:MiracleAnimation = _instance as MiracleAnimation;
			//stop frame changing if playback direction equals 0
			if (instance.playbackDirection == 0)return;
			//calculate possibility of frame changing
			instance.timePassed += _passedTime;
			var count:int = instance.timePassed / instance.frameDelta;
			while (instance.timePassed > instance.frameDelta)
				instance.timePassed -= instance.frameDelta;
			instance.currentFrame += count * instance.playbackDirection;
			if(instance.playbackDirection > 0 && instance.currentFrame < _iAnimationHelper.totalFrames)return;
			else if(instance.playbackDirection < 0 && instance.currentFrame >= 0)return;
			//check end of playback
			if(instance.playbackDirection > 0)
			{

				while(instance.currentFrame >= _iAnimationHelper.totalFrames)
					instance.currentFrame -= _iAnimationHelper.totalFrames;
				if(!instance.loop)
				{
					instance.currentFrame = _iAnimationHelper.totalFrames - 1;
					instance.miracle_internal::stopPlayback();
				}
			}
			else if(instance.playbackDirection < 0)
			{
				if(instance.loop)
				{
					while(instance.currentFrame < 0 )
						instance.currentFrame = _iAnimationHelper.totalFrames - count;
				}else
				{
					instance.currentFrame = 0;
					instance.miracle_internal::stopPlayback();
				}
			}
		}

		//draw parts methods
		[Inline]
		private final function drawTriangles():void
		{
			var n:int;
			_indexData.position = 0;
			_verticesData.position = 0;
			if (_verticesDataLength > 0)
			{
				n = (_verticesDataLength >> 2) / VERTEX_PARAMS_LENGTH;
				_vertexBuffer = _context.createVertexBuffer(n, VERTEX_PARAMS_LENGTH);
				_vertexBuffer.uploadFromByteArray(_verticesData, 0, 0, n);
				n = _indexDataLength >> 1;
				_indexBuffer = _context.createIndexBuffer(n);
				_indexBuffer.uploadFromByteArray(_indexData, 0, 0, n);
				_context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //x, y
				_context.setVertexBufferAt(1, _vertexBuffer, XY, Context3DVertexBufferFormat.FLOAT_2); //u, v
				_context.setVertexBufferAt(2, _vertexBuffer, XY + UV, Context3DVertexBufferFormat.FLOAT_4); //tx, ty, offsetX, offsetY
				_context.setVertexBufferAt(3, _vertexBuffer, XY + UV + OFFSET, Context3DVertexBufferFormat.FLOAT_4); //scaleX, scaleY, skewX, skewY
				_context.setVertexBufferAt(4, _vertexBuffer, XY + UV + OFFSET + TRANSFORM, Context3DVertexBufferFormat.FLOAT_4); //R, G, B, A
				_context.setVertexBufferAt(5, _vertexBuffer, VERTEX_PARAMS_LENGTH - CMULT, Context3DVertexBufferFormat.FLOAT_4); //multiplierR, multiplierG, multiplierB, multiplierA
				_context.drawTriangles(_indexBuffer);

				_vertexBuffer.dispose();
				_indexBuffer.dispose();
			}
			_indexStep = 0;
			//
			_verticesDataLength = 0;
			_indexDataLength = 0;
		}

		[Inline]
		private final function draw():void
		{
			var i:int;
			var n:int = _polygon.numVertices;
			//====
			//set vertexes
			for (i = 0; i < n; i++)
			{
				/**** ADD VERTEX & UV DATA *****/
				_verticesData.writeBytes(_polygon.buffer, i * Polygon2D.BUFFER_SIZE, Polygon2D.BUFFER_SIZE);
				/**** ADD TRANSFORM INDEXES DATA *****/
				_verticesData.writeBytes(_currentMatrix, 0, MATRIX_SIZE);
			}
			//add length
			_verticesDataLength += Polygon2D.BUFFER_SIZE * n + MATRIX_SIZE * n;
			/**** FILL INDEXES BUFFER *****/
			n = _polygon.indexes.length;
			for (i = 0; i < n; i++)
			{
				_indexData.writeShort(_indexStep + _polygon.indexes[i]);
			}
			_indexDataLength += n * 2;
			_indexStep += _polygon.numVertices;
		}

		//static
		/**
		 * Calculate new matrix transformation for processed polygon
		 * @param m0 instance matrix transformation
		 * @param m1 initial matrix transformation
		 */
		[Inline]
		private final function staticMatrix(m0:TransformMatrix, m1:TransformMatrix):void
		{
			/**** CALCULATE FORM TRANSFORMATIONS *****/
			_currentMatrix.writeFloat(m0.tx + m1.tx * m0.scaleX);//tx
			_currentMatrix.writeFloat(m0.ty + m1.ty * m0.scaleY);//ty
			_currentMatrix.writeFloat(m1.offsetX);//offsetX
			_currentMatrix.writeFloat(m1.offsetY);//offsetY
			_currentMatrix.writeFloat(m0.scaleX * m1.scaleX);//scaleX
			_currentMatrix.writeFloat(m0.scaleY * m1.scaleY);//scaleY
			_currentMatrix.writeFloat(m0.skewX + m1.skewX);//skewX
			_currentMatrix.writeFloat(m0.skewY + m1.skewY);//skewY
		}

		/**
		 * Calculate new color transformation for processed polygon
		 * @param c0 instance color transformation
		 * @param c1 initial color transformation
		 */
		[Inline]
		private final function staticColor(c0:Color, c1:Color):void
		{
			/**** CALCULATE COLOR TRANSFORMATIONS *****/
			var different:uint = c0.type | c1.type;
			var mask:uint = different & Color.COLOR;
			_currentMatrix.position = TRANSFORM_SIZE;
			//If one of the colors has some transformation that need to calculate new c0 c0
			if (mask == Color.COLOR)
			{
				//calculate offsets
				_currentMatrix.writeFloat(c0.redOffset + c1.redOffset);//RED
				_currentMatrix.writeFloat(c0.greenOffset + c1.greenOffset);//GREEN
				_currentMatrix.writeFloat(c0.blueOffset + c1.blueOffset);//BLUE
				//calculate multipliers
				_currentMatrix.position = MULTIPLIER_OFFSET;
				_currentMatrix.writeFloat(c0.redMultiplier + c1.redMultiplier);//RED
				_currentMatrix.writeFloat(c0.greenMultiplier + c1.greenMultiplier);//GREEN
				_currentMatrix.writeFloat(c0.blueMultiplier + c1.blueMultiplier);//BLUE
			}
			mask = different & Color.ALPHA;
			if (mask == Color.ALPHA)
			{
				//calculate offsets
				_currentMatrix.position = ALPHA_OFFSET;
				_currentMatrix.writeFloat(c0.alphaOffset + c1.alphaOffset);//ALPHA
				//calculate multipliers
				_currentMatrix.position = ALPHA_MULTIPLIER_OFFSET;
				_currentMatrix.writeFloat(c0.alphaMultiplier + c1.alphaMultiplier);//ALPHA

			}
		}

		//Motion
		/**
		 * Calculate new matrix transformation for processed polygon
		 * @param m0 instance matrix transformation
		 * @param m1 initial matrix transformation
		 * @param m2 terminal matrix transformation
		 * @param t Time delta for formula: matrix = m0 + ( ( 1 - t ) * m1 + t * m2 )
		 */
		[Inline]
		private final function motionMatrix(m0:TransformMatrix, m1:TransformMatrix, m2:TransformMatrix, t:Number):void
		{
			var t0:Number = 1 - t;
			/**** CALCULATE FORM TRANSFORMATIONS *****/
			_currentMatrix.writeFloat(m0.tx + (t0 * m1.tx + t * m2.tx ) * m0.scaleX);//tx
			_currentMatrix.writeFloat(m0.ty + ( t0 * m1.ty + t * m2.ty ) * m0.scaleY);//ty
			_currentMatrix.writeFloat(t0 * m1.offsetX + t * m2.offsetX);//offsetX
			_currentMatrix.writeFloat(t0 * m1.offsetY + t * m2.offsetY);//offsetY
			_currentMatrix.writeFloat(m0.scaleX * (t0 * m1.scaleX + t * m2.scaleX));//scaleX
			_currentMatrix.writeFloat(m0.scaleY * (t0 * m1.scaleY + t * m2.scaleY));//scaleY
			_currentMatrix.writeFloat(m0.skewX + (t0 * m1.skewX + t * m2.skewX ) * m0.flipX);//skewX
			_currentMatrix.writeFloat(m0.skewY + (t0 * m1.skewY + t * m2.skewY ) * m0.flipX);//skewY
		}

		/**
		 * Calculate new color transformation for processed polygon
		 * @param c0 instance color transformation
		 * @param c1 initial color transformation
		 * @param c2 terminal color transformation
		 * @param t Time delta for formula: color = c0 + ( ( 1 - t ) * c1 + t * c2 )
		 */
		[Inline]
		private final function motionColor(c0:Color, c1:Color, c2:Color, t:Number):void
		{
			/**** CALCULATE COLOR TRANSFORMATIONS *****/
			var t0:Number = 1 - t;
			var different:uint = c0.type | c1.type | c2.type;
			var mask:uint = different & Color.COLOR;
			_currentMatrix.position = TRANSFORM_SIZE;
			//If one of the colors has some transformation that need to calculate new c0 c0
			if (mask == Color.COLOR)
			{
				//calculate offsets
				_currentMatrix.writeFloat(c0.redOffset +
						(t0 * c1.redOffset + t * c2.redOffset));//RED
				_currentMatrix.writeFloat(c0.greenOffset +
						(t0 * c1.greenOffset + t * c2.greenOffset));//GREEN
				_currentMatrix.writeFloat(c0.blueOffset +
						(t0 * c1.blueOffset + t * c2.blueOffset));//BLUE
				//calculate multipliers
				_currentMatrix.position = MULTIPLIER_OFFSET;
				_currentMatrix.writeFloat(c0.redMultiplier +
						(t0 * c1.redMultiplier + t * c2.redMultiplier));//RED
				_currentMatrix.writeFloat(c0.greenMultiplier +
						(t0 * c1.greenMultiplier + t * c2.greenMultiplier));//GREEN
				_currentMatrix.writeFloat(c0.blueMultiplier +
						(t0 * c1.blueMultiplier + t * c2.blueMultiplier));//BLUE
			}
			mask = different & Color.ALPHA;
			if (mask == Color.ALPHA)
			{
				//calculate offsets
				_currentMatrix.position = ALPHA_OFFSET;
				_currentMatrix.writeFloat(c0.alphaOffset +
						(t0 * c1.alphaOffset + t * c2.alphaOffset));//ALPHA
				//calculate multipliers
				_currentMatrix.position = ALPHA_MULTIPLIER_OFFSET;
				_currentMatrix.writeFloat(c0.alphaMultiplier +
						(t0 * c1.alphaMultiplier + t * c2.alphaMultiplier));//ALPHA

			}
		}

		private function drawScreenShot():void
		{
			var bitmapData:BitmapData = new BitmapData(_screenShotSize.x, _screenShotSize.y, false);
			_context.drawToBitmapData(bitmapData);
			_screenShotCallback.call(this, bitmapData);
			_drawScreenShot = false;
			_screenShotCallback = null;
			_screenShotSize = null;
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