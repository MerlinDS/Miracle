/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:39
 * Coied form com.salazkin.framework.Shape
 */
package com.merlinds.miracle.geom {
	/**
	 * Object of this class contains information about 2D polygon.
	 */
	public class Polygon2D {

		/** Scale value for polygon **/
		private var _scale:Number;
		/** List of indexes for points in polygon **/
		public var indexes:Vector.<int>;
		/** Buffer that contains vertices and uvs information **/
		public var buffer:Vector.<Number>;
		/** Number of vertices of polygon in buffer **/
		public var numVertices:Number;
		/**
		 * Constructor
		 * @param indexes List of indexes for point in polygon
		 * @param vertices List of vertices in polygon
		 * @param uvs List of UV coordinates in texture for polygon point
		 */
		public function Polygon2D(indexes:Vector.<int>, vertices:Vector.<Number>, uvs:Vector.<Number>) {
			_scale = 1;//Set default value of scale
			this.numVertices = vertices.length >> 1;
			this.indexes = new Vector.<int>( indexes.length );
			this.buffer = new Vector.<Number>( this.numVertices * 4 );
			//fill buffer by vertices and uv coordinates
			var i:uint;
			var dataIndex:int = 0;
			var n:int = this.numVertices;
			for(i = 0; i < n; i++){
				this.buffer[dataIndex++] = vertices[ i * 2 ];
				this.buffer[dataIndex++] = vertices[ i * 2 + 1 ];
				this.buffer[dataIndex++] = uvs[ i * 2 ];
				this.buffer[dataIndex++] = uvs[ i * 2 + 1 ];
			}
			//copy data indexes list
			this.indexes = indexes.concat();
		}
		//==============================================================================
		//{region							PUBLIC METHODS
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		/** @private **/
		public function get scale():Number {
			return _scale;
		}

		/**
		 * Scale value for polygon. New value will update polygon buffer
		 * @default 1
		 **/
		public function set scale(value:Number):void {
			//prevent unnecessary changes
			if(value != _scale){
				_scale = value;
				/*
					Update vertices in buffer with new scale value.
					Each 2 items are vertices that buffer contains 2 uv coordinates.
				 */
				var n:int = this.buffer.length;
				for(var i:uint = 0; i < n; i+=4){
					this.buffer[i] = this.buffer[i] * _scale;
					this.buffer[i + 1] = this.buffer[i + 1] * _scale;
				}
			}
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}
