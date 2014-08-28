/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:39
 * Coied form com.salazkin.framework.Shape
 */
package com.merlinds.miracle.meshes {
	public class Polygon2D {

		public var buffer:Vector.<Number>;
		public var indexes:Vector.<Number>;
		public var numVertexes:Number;

		public function Polygon2D(data:Object, scale:Number = 1) {
			this.numVertexes = data.vertexes.length >> 1;
			this.indexes = new Vector.<Number>( data.indexes.length );
			this.buffer = new Vector.<Number>( this.numVertexes * 4 );

			var i:uint;
			var dataIndex:int = 0;
			var n:int = this.numVertexes;
			for(i = 0; i < n; i++){
				this.buffer[dataIndex++] = data.vertexes[ i * 2 ] * scale;
				this.buffer[dataIndex++] = data.vertexes[ i * 2 + 1 ] * scale;
				this.buffer[dataIndex++] = data.uv[ i * 2 ];
				this.buffer[dataIndex++] = data.uv[ i * 2 + 1 ];
			}

			n = data.indexes.length;
			for(i = 0; i < n; i++){
				indexes[i] = data.indexes[i];
			}
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
		//} endregion GETTERS/SETTERS ==================================================
	}
}
