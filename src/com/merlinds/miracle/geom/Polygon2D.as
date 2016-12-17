/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:39
 * Coied form com.salazkin.framework.Shape
 */
package com.merlinds.miracle.geom {
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class Polygon2D {

		public static const BUFFER_SIZE:int = 4 * 4;//4 field * 4 bytes

		public var indexes:Vector.<int>;
		public var buffer:ByteArray;
		public var numVertices:Number;

		//TODO DO not create buffer used precreated instead
		public function Polygon2D(data:Object, scale:Number = 1) {
			this.numVertices = data.vertexes.length >> 1;
			this.indexes = new Vector.<int>( data.indexes.length );
			this.buffer = new ByteArray();
			this.buffer.endian = Endian.LITTLE_ENDIAN;

			var i:uint;
			var n:int = this.numVertices;
			for(i = 0; i < n; i++){
				this.buffer.writeFloat(data.vertexes[ i * 2 ] * scale);
				this.buffer.writeFloat(data.vertexes[ i * 2 + 1 ] * scale);
				this.buffer.writeFloat(data.uv[ i * 2 ]);
				this.buffer.writeFloat(data.uv[ i * 2 + 1 ]);
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
