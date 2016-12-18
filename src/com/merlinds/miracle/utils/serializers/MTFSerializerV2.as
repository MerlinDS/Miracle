/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2016. Near Fancy
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package com.merlinds.miracle.utils.serializers
{
	import com.merlinds.miracle.geom.Mesh2D;
	import com.merlinds.miracle.geom.Polygon2D;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.setTimeout;
	
	/**
	 * MTF (Miracle texture format) serializer.
	 * Protocol version 2.0
	 *
	 * @inheritDoc
	 */
	internal class MTFSerializerV2 extends MTFSerializer
	{
		//region Constants
		/**
		 * Build in indexes of vertices
		 */
		private static const _indexes:Vector.<int> = new <int>[0,3,1,2,1,3];
		/**
		 * Size of coordinates arrays
		 */
		private static const ARRAY_SIZE:int = 8;
		/** Size of alias index in bytes */
		private static const CHARS_SIZE:int = 4;
		/** Size of list of (<code>float32</code>) uv coordinates: 4 * 8  bytes */
		private static const UV_SIZE:int = 4 * ARRAY_SIZE;
		/** Size of list of (<code>int32</code>) vertices coordinates: 4 * 8  bytes */
		private static const VERTICES_SIZE:int = 4 * ARRAY_SIZE;
		/** Total size of polygon chunk in bytes */
		private static const CHUNK_SIZE:int = CHARS_SIZE + UV_SIZE + VERTICES_SIZE;
		/** Size of head chunk in bytes**/
		private static const HEAD_SIZE:int = CHARS_SIZE + 4 /*count*/ + 4 /*offset*/;
		//endregion
		
		//region Properties
		private var _dictSerializer:DictionarySerializer;
		//endregion
		
		public function MTFSerializerV2()
		{
			super( MTFSerializer.V2, Endian.LITTLE_ENDIAN );
			_dictSerializer = new DictionarySerializer('us-ascii', endian);
		}
		
		
		//region Serialization
		/**
		 * Concrete serialization method realization
		 * @param data Data object than need to be serialized.
		 * Indexes will be ignored for this version of protocol.
		 * @example
		 * //Data object structure
		 *
		 * [{
		 * 	mesh:[
		 * 		//list of parts
		 * 		{
		 * 			name:[name of the polygon],
		 * 			indexes:[0,3,1,2,1,3],
		 * 			uv:[8 values of UV coordinates ],
		 *			vertices:[8 values of vertices coordinates]
		 * 		}]
		 * 	},
		 * 	...
		 * ]
		 *
		 * @param output <code>ByteArray</code> of serialized MTF
		 */
		override protected function executeSerialization(data:Object, output:ByteArray):void
		{
			var polygons:Array;
			var position:int, i:int, n:int;
			n = data.length;
			//write aliases dict
			var aliases:ByteArray = _dictSerializer.serializeFromObject(data);
			output.writeBytes(aliases, 0, aliases.length);
			//write header
			var offset:int = n * HEAD_SIZE;//Set to end of header
			output.writeInt(n);//Save count of meshes
			//write meshes data to header, names and size of chunks list
			for(i = 0; i < n; ++i)
			{
				var name:int = data[i].name;
				polygons = data[i].mesh;
				if(polygons == null)
					throw new ArgumentError("Mesh has no polygons field!");
				//write name and go to size data position
				position = output.position;
				output.writeInt(name);
				output.position = position + CHARS_SIZE;
				//write size data
				output.writeInt(polygons.length);//count of polygons
				output.writeInt(offset);//polygons starting offset
				offset += polygons.length * CHUNK_SIZE;//update offset for next mesh
			}
			//write polygons
			for(i = 0; i < n; ++i)
			{
				polygons = data[i].mesh;
				for each (var polygon:Object in polygons)
					writePolygon(polygon, output);
			}
		}
		
		/**
		 * Write mesh polygon to output:
		 * Each of polygon in mesh is a chunk that has structure:
		 * <ul>
		 * 	<li>name</li>
		 * 	<li>uv</li>
		 * 	<li>vertices</li>
		 *	</ul>
		 * @param data Mesh data
		 * @param output Output bytes
		 *
		 * @see MTFSerializerV2.CHUNK_SIZE Total size of chunk
		 * @see MTFSerializerV2.CHARS_SIZE Size of the name filed
		 * @see MTFSerializerV2.UV_SIZE Size of uv array
		 * @see MTFSerializerV2.VERTICES_SIZE Size of vertices array
		 */
		[Inline]
		private final function writePolygon(data:Object, output:ByteArray):void
		{
			/*
			 	Can be modified in future versions of protocol.
			 	But for V2 indexes of vertices is built in
				var indexes:Array = data.indexes;
			 */
			if(data.name == null)
				throw new ArgumentError("Polygon hasn't name field");
			if(data.uv == null || data.uv.length != ARRAY_SIZE)
				throw new ArgumentError("Polygon field uv is invalid or null!");
			if(data.vertices == null || data.vertices.length != ARRAY_SIZE)
				throw new ArgumentError("Polygon field vertices is invalid or null!");
			//write chunk to output
			var start:int = output.position;
			//write name of polygon
			output.writeInt(data.name);
			output.position = start + CHARS_SIZE;
			//write uv array
			var i:int;
			for(i = 0; i < ARRAY_SIZE; ++i)
				output.writeFloat(data.uv[i]);
			//write vertices array
			for(i = 0; i < ARRAY_SIZE; ++i)
				output.writeInt(data.vertices[i]);
		}
		//endregion
		
		//region Deserialization
		/**
		 * Read meshes from bytes and save them to output
		 * @param bytes MTF bytes
		 * @param output output dictionary
		 * @param scale Global scene scale (need for Polygon building)
		 * @param alias Texture alias for meshes
		 */
		override protected function executeDeserialization(bytes:ByteArray, output:Dictionary, scale:Number, alias:String):void
		{
			var aliases:Vector.<String> = _dictSerializer.deserialize(bytes);
			var i:int, n:int = bytes.readInt();
			var start:int = bytes.position;
			for(i = 0; i < n; ++i)
			{
				//read meshes
				bytes.position = start + HEAD_SIZE * i;
				var name:String = aliases[ bytes.readInt() ];
				var count:int = bytes.readInt();
				var offset:int = bytes.readInt();
				var mesh:Mesh2D = new Mesh2D(alias, scale);
				if(output.name != null)
					trace("WARNING: mesh with name" + name + "will be overridden");
				output[name] = mesh;
				//read polygons
				bytes.position = start + offset;
				deserializePolygons(bytes, aliases, count, mesh);
			}
			setTimeout(deserializationComplete, 0);//wait for next frame
		}
		
		[Inline]
		private final function deserializePolygons(bytes:ByteArray, aliases:Vector.<String>,
												   count:int, mesh:Mesh2D):void
		{
			var i:int, j:int;
			var uv:Vector.<Number> = new <Number>[];
			var vertices:Vector.<Number> = new <Number>[];
			uv.length = vertices.length = ARRAY_SIZE;
			for(i = 0; i < count; ++i)
			{
				var name:String = aliases[ bytes.readInt() ];
				var polygon:Polygon2D = new Polygon2D(_indexes.concat(), 4);
				polygon.buffer.endian = endian;
				for(j = 0; j < ARRAY_SIZE; ++j)
					uv[j] = bytes.readFloat();
				for(j = 0; j < ARRAY_SIZE; ++j)
					vertices[j] = bytes.readInt();
				//write polygon buffer
				for(j = 0; j < polygon.numVertices; ++j)
				{
					polygon.buffer.writeFloat(vertices[ j * 2 ] * mesh.scale);
					polygon.buffer.writeFloat(vertices[ j * 2 + 1 ] * mesh.scale);
					polygon.buffer.writeFloat(uv[ j * 2 ]);
					polygon.buffer.writeFloat(uv[ j * 2 + 1 ]);
				}
//				data, mesh.scale
				mesh[name] = polygon;
			}
		}
		//endregion
	}
}
