/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:36
 */
package com.merlinds.miracle {
	import com.merlinds.miracle.display.MiracleAnimation;
	import com.merlinds.miracle.display.MiracleDisplayObject;
	import com.merlinds.miracle.display.MiracleImage;
	import com.merlinds.miracle.meshes.Mesh2D;
	import com.merlinds.miracle.meshes.Polygon2D;
	import com.merlinds.miracle.textures.TextureHelper;
	import com.merlinds.miracle.utils.Asset;
	import com.merlinds.miracle.utils.DrawingMatrix;

	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Vector3D;

	internal class Scene extends AbstractScene implements IScene{
		/**
		 * [x,y] + [u,v] + [tx, ty] + [scaleX, scaleY, skewX, skewY] + [r,g,b,a]
		 */
		private const VERTEX_PARAMS_LENGTH:int = 2 + 2 + 2 + 4;
		//GPU
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _vertexData:Vector.<Number>;
		private var _indexData:Vector.<uint>;

		//
		use namespace miracle_internal;

		public function Scene(assets:Vector.<Asset>) {
			_vertexData = new <Number>[];
			_indexData = new <uint>[];
			super(assets);
		}

		//==============================================================================
		//{region							PUBLIC METHODS
		//IScene
		public function createImage(meshName:String, textureName:String, position:Vector3D = null, serializer:Class = null):MiracleImage {
			var mesh:Mesh2D = _meshes[meshName];
			var textureHelper:TextureHelper = _textures[textureName];

			//TODO add validation
			if(mesh == null){
				throw ArgumentError("Cannot find mesh with name " + meshName);
			}

			if(textureHelper == null){
				throw ArgumentError("Cannot find texture with name " + textureName);
			}

			var instance:MiracleDisplayObject = new MiracleImage(textureName);
			_displayObjects[_displayObjects.length++] = instance;
			if(position != null){
				instance.drawMatrix.tx = position.x;
				instance.drawMatrix.ty = position.y;
			}
			//add texture to gpu
			//TODO add sharing one texture between few materials
			var texture:Texture = _context.createTexture(textureHelper.width,
					textureHelper.height, textureHelper.format, true);
			texture.uploadCompressedTextureFromByteArray(textureHelper.bytes, 0);
			textureHelper.texture = texture;
			trace("Miracle: Image was created. Material name:", texture);
			return instance as MiracleImage;
		}

		public function createAnimation(name:String, position:Vector3D = null, serializer:Class = null):MiracleAnimation
		{
			var instance:MiracleAnimation;
			trace("Miracle: Animation was created. Name:", name);
			return instance;
		}

//IRenderer
		override public function end():void{
			this.drawTriangles();
			_context.present();
		}

		override public function drawFrame():void{
			/*var mesh:Polygon2D;
			var material:Material;
			var instance:MiracleDisplayObject;
			var n:int = _displayObjects.length;
			for(var i:int = 0; i < n; i++){
				instance = _displayObjects[i];
				material = _materials[ instance.materialName ];
				instance.drawMatrix.tx++;
				mesh = material.meshList[0];//TODO add mesh index to instance
				_context.setTextureAt(0, material.texture);
				this.draw(mesh, instance.drawMatrix);
			}*/

		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS

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
				_context.drawTriangles( _indexBuffer );
			}
			_vertexOffset = 0;
			_indexOffset = 0;
			_indexStep = 0;
			//
			_vertexData.length = 0;
			_indexData.length = 0;
		}

		//TODO: refactor this
		private var _vertexOffset:Number = 0;
		private var _indexOffset:Number = 0;
		private var _indexStep:Number = 0;

		[Inline]
		private function draw(mesh:Polygon2D, dm:DrawingMatrix):void {
			var i:int;
			var dataIndex:int = 0;
			var n:int = mesh.numVertexes;
			for(i = 0; i < n; i++){
				/**** ADD VERTEX DATA *****/
				_vertexData[_vertexOffset++] = mesh.buffer[ dataIndex++ ] + dm.offsetX;
				_vertexData[_vertexOffset++] = mesh.buffer[ dataIndex++ ] + dm.offsetY;
				/**** ADD UV DATA *****/
				_vertexData[_vertexOffset++] = mesh.buffer[ dataIndex++ ];
				_vertexData[_vertexOffset++] = mesh.buffer[ dataIndex++ ];
				/**** ADD TRANSFORM INDEXES DATA *****/
				_vertexData[_vertexOffset++] = dm.tx;
				_vertexData[_vertexOffset++] = dm.ty;
				_vertexData[_vertexOffset++] = dm.scaleX;
				_vertexData[_vertexOffset++] = dm.scaleY;
				_vertexData[_vertexOffset++] = dm.skewX;
				_vertexData[_vertexOffset++] = dm.skewY;
				/**** ADD COLOR DATA *****/
				/*
				_vertexData[_vertexOffset++] = dm.color[0];
				_vertexData[_vertexOffset++] = dm.color[1];
				_vertexData[_vertexOffset++] = dm.color[2];
				_vertexData[_vertexOffset++] = dm.color[3];
				*/
			}
			/**** FILL INDEXES BUFFER *****/
			n = mesh.indexes.length;
			for(i = 0; i < n; i++){
				_indexData[_indexOffset++] = _indexStep + mesh.indexes[i];
			}
			_indexStep += mesh.numVertexes;
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
